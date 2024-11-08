import pytest
from meal_max.models.kitchen_model import create_meal, delete_meal, get_meal_by_id, get_meal_by_name, update_meal_stats, Meal

@pytest.fixture
def sample_meal():
    return {
        "meal": "Pizza",
        "cuisine": "Italian",
        "price": 10.99,
        "difficulty": "LOW"
    }

##################################################
# Meal Management Test Cases
##################################################

def test_create_meal(sample_meal):
    """Test creating a new meal."""
    create_meal(**sample_meal)
    meal = get_meal_by_name("Pizza")
    assert meal is not None, "Expected meal 'Pizza' to be created"
    assert meal.price == 10.99, f"Expected price 10.99, got {meal.price}"

def test_create_meal_invalid_price():
    """Test error when creating a meal with an invalid price."""
    with pytest.raises(ValueError, match="Price must be a positive number"):
        create_meal("Burger", "American", -5.0, "MED")

def test_delete_meal(sample_meal):
    """Test deleting a meal by ID."""
    create_meal(**sample_meal)
    meal = get_meal_by_name("Pizza")
    delete_meal(meal.id)
    with pytest.raises(ValueError, match="Meal has been deleted"):
        get_meal_by_id(meal.id)

def test_update_meal_stats_win(sample_meal):
    """Test updating meal stats with a win."""
    create_meal(**sample_meal)
    meal = get_meal_by_name("Pizza")
    update_meal_stats(meal.id, 'win')
    updated_meal = get_meal_by_id(meal.id)
    assert updated_meal.wins == 1, f"Expected 1 win, got {updated_meal.wins}"

