extends GutTest

func _repo() -> SaveRepository:
	return SaveRepository.new()

func test_save_and_load():
	var repo := _repo()
	var snapshot := {"case_version": "1", "step": "case_board", "matrices": {}}
	assert_eq(repo.save(snapshot), OK)
	var loaded := repo.load_valid("1")
	assert_eq(loaded.get("step"), "case_board")

func test_rejects_bad_version():
	var repo := _repo()
	repo.save({"case_version": "1", "step": "x"})
	var loaded := repo.load_valid("2")
	assert_true(loaded.is_empty())

func test_discard():
	var repo := _repo()
	repo.save({"case_version": "1", "step": "x"})
	repo.discard()
	assert_true(repo.load_valid("1").is_empty())
