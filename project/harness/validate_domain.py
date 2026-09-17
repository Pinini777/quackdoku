"""
QuackDoku MVP — Work Unit 1 Harness
Standalone Python validation of the Godot domain logic because the
Godot editor/runtime is not available in this environment.
"""
from __future__ import annotations

import hashlib
import itertools
import json
import os
import sys
import tempfile
from pathlib import Path


# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------

def _load_json(path: str) -> dict:
    target = Path(path)
    if not target.exists():
        return {}
    try:
        return json.loads(target.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return {}


# -----------------------------------------------------------------------------
# Domain mirrors of the GDScript classes
# -----------------------------------------------------------------------------

UNKNOWN, EXCLUDED, CONFIRMED = range(3)
OP_EQUALS, OP_NOT_EQUALS, OP_BEFORE, OP_ADJACENT = range(4)


class Constraint:
    def __init__(self, category_a, value_a, op, category_b, value_b):
        self.category_a = category_a
        self.value_a = value_a
        self.op = op
        self.category_b = category_b
        self.value_b = value_b

    def to_dict(self):
        return {
            "category_a": self.category_a,
            "value_a": self.value_a,
            "op": self.op,
            "category_b": self.category_b,
            "value_b": self.value_b,
        }

    @classmethod
    def from_dict(cls, d):
        return cls(d["category_a"], d["value_a"], d["op"], d["category_b"], d["value_b"])


class CaseDefinition:
    def __init__(self):
        self.title = ""
        self.version = "1"
        self.categories = {}
        self.constraints = []
        self.murderer_category = ""
        self.murderer_value = ""

    def to_dict(self):
        return {
            "title": self.title,
            "version": self.version,
            "categories": self.categories,
            "constraints": [c.to_dict() for c in self.constraints],
            "murderer_category": self.murderer_category,
            "murderer_value": self.murderer_value,
        }

    @classmethod
    def from_dict(cls, d):
        def_ = cls()
        def_.title = d.get("title", "")
        def_.version = d.get("version", "1")
        def_.categories = d.get("categories", {})
        def_.constraints = [Constraint.from_dict(c) for c in d.get("constraints", [])]
        def_.murderer_category = d.get("murderer_category", "")
        def_.murderer_value = d.get("murderer_value", "")
        return def_


class CaseState:
    def __init__(self, definition: CaseDefinition):
        self.definition = definition
        self.matrices = {}
        self.history = []
        self._in_op = False
        cats = sorted(definition.categories.keys())
        for i in range(len(cats)):
            for j in range(i + 1, len(cats)):
                ca, cb = cats[i], cats[j]
                key = f"{ca}|{cb}"
                self.matrices[key] = {}
                for a in definition.categories[ca]:
                    for b in definition.categories[cb]:
                        self.matrices[key][f"{a}|{b}"] = UNKNOWN

    def _pair_key(self, ca, cb):
        return f"{ca}|{cb}" if ca < cb else f"{cb}|{ca}"

    def get_cell(self, ca, va, cb, vb):
        key = self._pair_key(ca, cb)
        vals = f"{va}|{vb}" if ca < cb else f"{vb}|{va}"
        return self.matrices.get(key, {}).get(vals, UNKNOWN)

    def set_cell(self, ca, va, cb, vb, state):
        key = self._pair_key(ca, cb)
        vals = f"{va}|{vb}" if ca < cb else f"{vb}|{va}"
        if key not in self.matrices or vals not in self.matrices[key]:
            return
        if self.matrices[key][vals] == state:
            return
        if not self._in_op:
            self.history.append({"type": "snapshot", "matrices": {k: dict(v) for k, v in self.matrices.items()}})
            self._in_op = True
        self.matrices[key][vals] = state
        if state == CONFIRMED:
            self._propagate(ca, va, cb, vb)

    def _propagate(self, ca, va, cb, vb):
        for other in self.definition.categories[ca]:
            if other != va and self.get_cell(ca, other, cb, vb) == UNKNOWN:
                self.set_cell(ca, other, cb, vb, EXCLUDED)
        for other in self.definition.categories[cb]:
            if other != vb and self.get_cell(ca, va, cb, other) == UNKNOWN:
                self.set_cell(ca, va, cb, other, EXCLUDED)

    def apply_constraint(self, c: Constraint):
        if c.op == OP_EQUALS:
            self.set_cell(c.category_a, c.value_a, c.category_b, c.value_b, CONFIRMED)
        elif c.op == OP_NOT_EQUALS:
            self.set_cell(c.category_a, c.value_a, c.category_b, c.value_b, EXCLUDED)
        self._in_op = False

    def undo(self):
        if not self.history:
            return
        last = self.history.pop()
        if last["type"] == "snapshot":
            self.matrices = {k: dict(v) for k, v in last["matrices"].items()}
        self._in_op = False


class ValidationResult:
    def __init__(self):
        self.valid = False
        self.solution_count = 0
        self.murderer_deterministic = False
        self.error = ""


class MoveResult:
    def __init__(self):
        self.accepted = False
        self.contradiction = False
        self.message = ""


class CaseSolver:
    def validate(self, definition: CaseDefinition) -> ValidationResult:
        res = ValidationResult()
        suspects = definition.categories.get("suspect", [])
        cats = dict(definition.categories)
        cats.pop("suspect", None)
        if not suspects or not cats:
            res.error = "Missing categories"
            return res
        solutions = []
        self._solve({}, suspects, cats, definition, solutions, 2)
        res.solution_count = len(solutions)
        res.valid = res.solution_count == 1
        if res.valid:
            murderer = self._murderer_for(solutions[0], definition)
            category_values = definition.categories.get(definition.murderer_category, [])
            res.murderer_deterministic = bool(murderer) and definition.murderer_value in category_values
        else:
            res.error = f"Expected exactly one solution, found {res.solution_count}"
        return res

    def _solve(self, assignment, suspects, categories, definition, solutions, limit):
        if len(solutions) > limit:
            return
        idx = len(assignment)
        if idx >= len(suspects):
            if self._satisfies(assignment, definition):
                solutions.append({k: v.copy() for k, v in assignment.items()})
            return
        s = suspects[idx]
        for combo in self._options(categories):
            if self._combo_used(combo, assignment):
                continue
            assignment[s] = combo
            if self._partial_ok(assignment, definition):
                self._solve(assignment, suspects, categories, definition, solutions, limit)
            del assignment[s]

    def _combo_used(self, combo, assignment):
        for cat, value in combo.items():
            for attrs in assignment.values():
                if attrs.get(cat) == value:
                    return True
        return False

    def _options(self, categories):
        keys = list(categories.keys())
        if not keys:
            return
        pools = [categories[k] for k in keys]
        for values in itertools.product(*pools):
            yield dict(zip(keys, values))

    def _satisfies(self, assignment, definition):
        return self._partial_ok(assignment, definition)

    def _partial_ok(self, assignment, definition):
        for c in definition.constraints:
            a = self._resolve(c.category_a, c.value_a, assignment)
            b = self._resolve(c.category_b, c.value_b, assignment)
            if not self._check(c.op, a, b, definition):
                return False
        return True

    def _resolve(self, category, value, assignment):
        if category == "suspect":
            return {"suspect": value, "attrs": assignment.get(value, {})}
        for s, attrs in assignment.items():
            if attrs.get(category) == value:
                return {"suspect": s, "attrs": attrs}
        return {}

    def _check(self, op, a, b, definition):
        if not a or not b:
            return True
        if not a["attrs"] or not b["attrs"]:
            return True
        if op == OP_EQUALS:
            return a["suspect"] == b["suspect"]
        if op == OP_NOT_EQUALS:
            return a["suspect"] != b["suspect"]
        ta = definition.categories["time"].index(a["attrs"].get("time", ""))
        tb = definition.categories["time"].index(b["attrs"].get("time", ""))
        if ta < 0 or tb < 0:
            return True
        if op == OP_BEFORE:
            return ta < tb
        return abs(ta - tb) == 1

    def _murderer_for(self, assignment, definition):
        if definition.murderer_category == "suspect":
            return definition.murderer_value
        for s, attrs in assignment.items():
            if attrs.get(definition.murderer_category) == definition.murderer_value:
                return s
        return ""

    def apply(self, state: CaseState, move: dict) -> MoveResult:
        res = MoveResult()
        current = state.get_cell(move["ca"], move["va"], move["cb"], move["vb"])
        if current != UNKNOWN and current != move["state"]:
            res.contradiction = True
            res.message = "Cell already marked differently"
            return res
        snapshot = self._snapshot(state)
        state.set_cell(move["ca"], move["va"], move["cb"], move["vb"], move["state"])
        if self._state_contradicts(state):
            self._restore(state, snapshot)
            res.contradiction = True
            res.message = "Move creates a contradiction"
            return res
        res.accepted = True
        return res

    def _snapshot(self, state: CaseState):
        return {
            "matrices": {k: dict(v) for k, v in state.matrices.items()},
            "history": list(state.history),
        }

    def _restore(self, state: CaseState, snapshot):
        state.matrices = {k: dict(v) for k, v in snapshot["matrices"].items()}
        state.history = list(snapshot["history"])

    def _state_contradicts(self, state: CaseState):
        cats = list(state.definition.categories.keys())
        for i in range(len(cats)):
            for j in range(i + 1, len(cats)):
                ca, cb = cats[i], cats[j]
                for a in state.definition.categories[ca]:
                    if sum(1 for b in state.definition.categories[cb] if state.get_cell(ca, a, cb, b) == CONFIRMED) > 1:
                        return True
                for b in state.definition.categories[cb]:
                    if sum(1 for a in state.definition.categories[ca] if state.get_cell(ca, a, cb, b) == CONFIRMED) > 1:
                        return True
        return False


class SaveRepository:
    def __init__(self, path: Path):
        self.path = path

    def _checksum(self, data: str) -> str:
        return hashlib.md5(data.encode("utf-8")).hexdigest()

    def save(self, snapshot: dict) -> bool:
        payload = dict(snapshot)
        payload["_checksum"] = self._checksum(json.dumps(snapshot, sort_keys=True))
        tmp = self.path.with_suffix(".tmp")
        self.path.parent.mkdir(parents=True, exist_ok=True)
        tmp.write_text(json.dumps(payload, sort_keys=True), encoding="utf-8")
        tmp.replace(self.path)
        return True

    def load_valid(self, case_version: str) -> dict:
        if not self.path.exists():
            return {}
        text = self.path.read_text(encoding="utf-8")
        try:
            result = json.loads(text)
        except json.JSONDecodeError:
            return {}
        if not isinstance(result, dict) or result.get("case_version") != case_version:
            return {}
        stored = result.get("_checksum", "")
        snapshot = {k: v for k, v in result.items() if not k.startswith("_")}
        if self._checksum(json.dumps(snapshot, sort_keys=True)) != stored:
            return {}
        return snapshot

    def discard(self):
        if self.path.exists():
            self.path.unlink()


# -----------------------------------------------------------------------------
# Test fixtures
# -----------------------------------------------------------------------------

SIMPLE_CASE = {
    "title": "Simple",
    "version": "1",
    "categories": {
        "suspect": ["A", "B"],
        "room": ["X", "Y"],
    },
    "constraints": [
        {"category_a": "suspect", "value_a": "A", "op": OP_EQUALS, "category_b": "room", "value_b": "X"},
        {"category_a": "suspect", "value_a": "B", "op": OP_NOT_EQUALS, "category_b": "room", "value_b": "X"},
    ],
    "murderer_category": "suspect",
    "murderer_value": "A",
}

UNIQUE_CASE = {
    "title": "Unique",
    "version": "1",
    "categories": {
        "suspect": ["A", "B", "C"],
        "room": ["X", "Y", "Z"],
        "time": ["1", "2", "3"],
        "item": ["P", "Q", "R"],
    },
    "constraints": [
        {"category_a": "suspect", "value_a": "A", "op": OP_EQUALS, "category_b": "room", "value_b": "X"},
        {"category_a": "suspect", "value_a": "B", "op": OP_NOT_EQUALS, "category_b": "room", "value_b": "X"},
        {"category_a": "suspect", "value_a": "B", "op": OP_EQUALS, "category_b": "time", "value_b": "2"},
        {"category_a": "suspect", "value_a": "C", "op": OP_BEFORE, "category_b": "suspect", "value_b": "B"},
        {"category_a": "suspect", "value_a": "A", "op": OP_EQUALS, "category_b": "item", "value_b": "P"},
        {"category_a": "suspect", "value_a": "B", "op": OP_NOT_EQUALS, "category_b": "item", "value_b": "Q"},
        {"category_a": "suspect", "value_a": "C", "op": OP_EQUALS, "category_b": "room", "value_b": "Z"},
    ],
    "murderer_category": "suspect",
    "murderer_value": "A",
}

# -----------------------------------------------------------------------------
# Harness runner
# -----------------------------------------------------------------------------

class Harness:
    def __init__(self):
        self.passed = 0
        self.failed = 0
        self.messages = []

    def check(self, name: str, condition: bool, detail: str = ""):
        if condition:
            self.passed += 1
            self.messages.append(f"PASS: {name}")
        else:
            self.failed += 1
            self.messages.append(f"FAIL: {name} {detail}")

    def run(self):
        print("=== QuackDoku MVP Work Unit 1 Harness ===\n")

        # CaseDefinition tests
        print("[CaseDefinition]")
        d = CaseDefinition.from_dict(SIMPLE_CASE)
        self.check("categories loaded", len(d.categories) == 2)
        self.check("operators preserved", len(d.constraints) == 2)
        self.check("serialization roundtrip", CaseDefinition.from_dict(d.to_dict()).version == "1")

        # CaseState tests
        print("\n[CaseState]")
        state = CaseState(d)
        self.check("initial unknown", state.get_cell("suspect", "A", "room", "X") == UNKNOWN)
        state.set_cell("suspect", "A", "room", "X", CONFIRMED)
        self.check("confirm propagates row", state.get_cell("suspect", "A", "room", "Y") == EXCLUDED)
        self.check("confirm propagates column", state.get_cell("suspect", "B", "room", "X") == EXCLUDED)
        state.undo()
        self.check("undo restores", state.get_cell("suspect", "A", "room", "X") == UNKNOWN)

        # CaseSolver tests
        print("\n[CaseSolver]")
        solver = CaseSolver()
        res = solver.validate(CaseDefinition.from_dict(SIMPLE_CASE))
        self.check("simple case unique", res.valid and res.solution_count == 1, res.error)
        self.check("simple murderer deterministic", res.murderer_deterministic)

        unique = CaseDefinition.from_dict(UNIQUE_CASE)
        res = solver.validate(unique)
        self.check("unique case solved", res.valid and res.solution_count == 1, res.error)
        self.check("unique murderer deterministic", res.murderer_deterministic)

        mansion_data = _load_json("project/data/cases/mansion_case.json")
        mansion = CaseDefinition.from_dict(mansion_data)
        res = solver.validate(mansion)
        self.check("mansion case loads", bool(mansion_data))
        self.check("mansion has exactly one solution", res.valid and res.solution_count == 1, res.error)
        self.check("mansion murderer is deterministic", res.murderer_deterministic)
        state = CaseState(d)
        move = {"ca": "suspect", "va": "A", "cb": "room", "vb": "X", "state": CONFIRMED}
        mr = solver.apply(state, move)
        self.check("valid move accepted", mr.accepted)
        mr = solver.apply(state, {"ca": "suspect", "va": "B", "cb": "room", "vb": "X", "state": CONFIRMED})
        self.check("duplicate confirmed rejected", mr.contradiction)

        # SaveRepository tests
        print("\n[SaveRepository]")
        with tempfile.TemporaryDirectory() as tmp:
            repo = SaveRepository(Path(tmp) / "progress-v1.json")
            snapshot = {"case_version": "1", "step": "case_board", "matrices": {}}
            self.check("save succeeds", repo.save(snapshot))
            loaded = repo.load_valid("1")
            self.check("load restores step", loaded.get("step") == "case_board")
            self.check("bad version rejected", repo.load_valid("2") == {})
            repo.save({"case_version": "1", "step": "x"})
            repo.path.write_text(repo.path.read_text().replace("x", "tampered"), encoding="utf-8")
            self.check("tampered save rejected", repo.load_valid("1") == {})
            repo.discard()
            self.check("discard removes", repo.load_valid("1") == {})

        # Tutorial and case content checks
        print("\n[Content]")
        tutorial_data = _load_json("project/data/dialogue/tutorial.json")
        self.check("tutorial json loads", bool(tutorial_data))
        self.check(
            "tutorial under five minutes",
            tutorial_data.get("max_seconds", 0) <= 300,
        )
        self.check("tutorial skip allowed", tutorial_data.get("allow_skip", False))
        steps = tutorial_data.get("steps", [])
        valid_rules = {"narrative", "row", "column", "clue", "complete"}
        gate_rules_ok = all(
            step.get("rule", "") in valid_rules
            for step in steps
            if step.get("type") == "gate"
        )
        self.check("tutorial gate rules valid", gate_rules_ok)
        self.check(
            "tutorial ends at mansion",
            tutorial_data.get("complete_transition") == "mansion_explore",
        )
        practice = CaseDefinition.from_dict(tutorial_data.get("practice_case", {}))
        practice_res = solver.validate(practice)
        self.check(
            "tutorial practice case unique",
            practice_res.valid and practice_res.solution_count == 1,
            practice_res.error,
        )

        mansion_dialogue = _load_json("project/data/dialogue/mansion.json")
        self.check("mansion dialogue loads", bool(mansion_dialogue))
        self.check(
            "mansion clue count matches constraints",
            len(mansion_dialogue.get("clues", [])) == len(mansion.constraints),
        )
        ending = mansion_dialogue.get("ending", {})
        self.check(
            "mansion ending has revelation",
            bool(ending.get("revelation", "")),
        )
        self.check(
            "mansion ending has collectible",
            bool(ending.get("collectible", {}).get("id", "")),
        )
        self.check(
            "mansion ending has self-contained hook",
            bool(ending.get("hook", "")),
        )

        # Source PNG preservation check
        print("\n[Source Preservation]")
        assets = Path("assets")
        pngs = list(assets.rglob("*.png")) if assets.exists() else []
        self.check("source PNGs present", len(pngs) > 0, str(pngs))

        print("\n=== Summary ===")
        for m in self.messages:
            print(m)
        print(f"\nPassed: {self.passed}  Failed: {self.failed}")
        return self.failed == 0


if __name__ == "__main__":
    os.chdir(Path(__file__).resolve().parents[2])  # project/harness -> repo root
    ok = Harness().run()
    sys.exit(0 if ok else 1)
