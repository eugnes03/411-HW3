import pytest
from meal_max.models.battle_model import BattleModel
from meal_max.models.kitchen_model import Meal

@pytest.fixture
def battle_model():
    """Fixture to provide a new instance of BattleModel for each test."""
    return BattleModel()

@pytest.fixture
def sample_meal1():
    return Meal(id=1, meal="Pizza", cuisine="Italian", price=10.99, difficulty="LOW")

@pytest.fixture
def sample_meal2():
    return Meal(id=2, meal="Sushi", cuisine="Japanese", price=12.99, difficulty="HIGH")

##################################################
# Combatant Management Test Cases
##################################################

def test_prep_combatant(battle_model, sample_meal1):
    """Test preparing a meal as a combatant."""
    battle_model.prep_combatant(sample_meal1)
    assert len(battle_model.get_combatants()) == 1
    assert battle_model.get_combatants()[0].meal == "Pizza"

def test_prep_combatant_duplicate(battle_model, sample_meal1):
    """Test error when preparing the same meal as a combatant twice."""
    battle_model.prep_combatant(sample_meal1)
    with pytest.raises(ValueError, match="Combatant list is full"):
        battle_model.prep_combatant(sample_meal1)

def test_clear_combatants(battle_model, sample_meal1, sample_meal2):
    """Test clearing all combatants."""
    battle_model.prep_combatant(sample_meal1)
    battle_model.prep_combatant(sample_meal2)
    battle_model.clear_combatants()
    assert len(battle_model.get_combatants()) == 0

##################################################
# Battle Test Cases
##################################################

def test_battle(battle_model, sample_meal1, sample_meal2, mocker):
    """Test initiating a battle between two combatants."""
    battle_model.prep_combatant(sample_meal1)
    battle_model.prep_combatant(sample_meal2)

    # Mock get_random to control the battle outcome
    mocker.patch('meal_max.utils.random_utils.get_random', return_value=0.2)
    winner = battle_model.battle()

    assert winner in [sample_meal1.meal, sample_meal2.meal], "Expected one of the combatants to win"

def test_battle_insufficient_combatants(battle_model):
    """Test error when trying to battle without enough combatants."""
    with pytest.raises(ValueError, match="Two combatants must be prepped for a battle"):
        battle_model.battle()

