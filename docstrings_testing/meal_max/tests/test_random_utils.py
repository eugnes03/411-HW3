import pytest
import requests
from meal_max.utils.random_utils import get_random

@pytest.fixture
def mock_random_org(mocker):
    """Mock the requests.get call to return a random number."""
    mock_response = mocker.Mock()
    mock_response.text = "0.42"
    mocker.patch("requests.get", return_value=mock_response)
    return mock_response

def test_get_random(mock_random_org):
    """Test retrieving a random number from random.org."""
    result = get_random()
    assert result == 0.42, f"Expected 0.42, but got {result}"
    requests.get.assert_called_once_with(
        "https://www.random.org/decimal-fractions/?num=1&dec=2&col=1&format=plain&rnd=new",
        timeout=5
    )

def test_get_random_timeout(mocker):
    """Simulate a timeout when calling random.org."""
    mocker.patch("requests.get", side_effect=requests.exceptions.Timeout)
    with pytest.raises(RuntimeError, match="Request to random.org timed out"):
        get_random()

def test_get_random_invalid_response(mock_random_org):
    """Simulate an invalid response from random.org."""
    mock_random_org.text = "invalid_response"
    with pytest.raises(ValueError, match="Invalid response from random.org"):
        get_random()

