from src.app import add, health


def test_add():
    assert add(2, 3) == 6


def test_health():
    assert health() == "ok"
