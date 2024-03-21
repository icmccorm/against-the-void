import shared
import unittest


class TestIndices(unittest.TestCase):
    def test_to_index(self):
        start = shared.coordinates_to_index("hello\nworld", 1, 1)
        assert start == 0
        end = shared.coordinates_to_index("hello\nworld", 1, 5)
        assert end == 4
        start = shared.coordinates_to_index("hello\nworld", 2, 1)
        assert start == 6

    def test_to_coords(self):
        line, col = shared.index_to_coordinates("hello\nworld", 0)
        assert line == 1
        assert col == 1
        line, col = shared.index_to_coordinates("hello\nworld", 5)
        assert line == 1
        assert col == 6
        line, col = shared.index_to_coordinates("hello\nworld", 6)
        assert line == 2
        assert col == 1

    def test_read_source(self):
        first = shared.get_source("./transcripts")
        second = shared.get_source("./transcripts")
        third = shared.get_source("./transcripts")
        assert first == second == third


if __name__ == "__main__":
    unittest.main()
