import json
import random
import uuid

# Load the existing foods.json file
with open('../BreadCrumb/Resources/foods.json', 'r') as f:
    data = json.load(f)

existing_foods = data['foods']
cuisines = data['cuisines']

# Define some common ingredients and descriptors for each cuisine
cuisine_ingredients = {
    'Indian': ['masala', 'paneer', 'naan', 'curry', 'chutney', 'biryani', 'dal', 'chapati', 'samosa', 'chaat', 'tikka', 'korma', 'vindaloo', 'raita', 'bhaji', 'pakora', 'tandoori', 'dosa', 'idli', 'uttapam'],
    'Mexican': ['taco', 'burrito', 'enchilada', 'quesadilla', 'salsa', 'guacamole', 'chilaquiles', 'mole', 'pozole', 'tamale', 'fajita', 'tostada', 'chimichanga', 'carnitas', 'elote', 'chiles', 'churro', 'ceviche', 'sopapilla', 'queso'],
    'Chinese': ['noodle', 'dumpling', 'fried rice', 'stir-fry', 'wonton', 'chow mein', 'lo mein', 'egg roll', 'sweet and sour', 'spring roll', 'dim sum', 'hot pot', 'bao', 'congee', 'chop suey', 'kung pao', 'szechuan', 'peking duck', 'char siu', 'hoisin'],
    'Middle Eastern': ['hummus', 'falafel', 'kebab', 'pita', 'tabbouleh', 'tahini', 'kibbeh', 'dolma', 'baba ganoush', 'fattoush', 'shawarma', 'baklava', 'halva', 'labneh', 'manakish', 'mujadara', 'kofta', 'sfiha', 'kanafeh', 'maamoul'],
    'African': ['couscous', 'tagine', 'injera', 'fufu', 'bobotie', 'egusi', 'jollof', 'bunny chow', 'chakalaka', 'piri piri', 'doro wat', 'pap', 'suya', 'akara', 'ful medames', 'shakshouka', 'matoke', 'ugali', 'muamba', 'mafe'],
    'Thai': ['pad thai', 'curry', 'tom yum', 'som tam', 'massaman', 'spring roll', 'satay', 'larb', 'tom kha', 'khao pad', 'panang', 'mango sticky rice', 'pad see ew', 'khao soi', 'yam', 'gai yang', 'pla pao', 'pad kra pao', 'mee krob', 'khanom'],
    'Japanese': ['sushi', 'ramen', 'tempura', 'sashimi', 'udon', 'teriyaki', 'yakitori', 'onigiri', 'donburi', 'gyoza', 'miso', 'takoyaki', 'okonomiyaki', 'shabu-shabu', 'sukiyaki', 'katsu', 'yakisoba', 'tamagoyaki', 'unagi', 'mochi'],
    'Italian': ['pasta', 'pizza', 'risotto', 'carbonara', 'lasagna', 'bruschetta', 'gnocchi', 'tiramisu', 'minestrone', 'pesto', 'cannoli', 'ravioli', 'parmigiana', 'osso buco', 'ciabatta', 'focaccia', 'polenta', 'arancini', 'bolognese', 'cacciatore'],
    'Greek': ['souvlaki', 'gyro', 'moussaka', 'tzatziki', 'spanakopita', 'dolmades', 'baklava', 'feta', 'pastitsio', 'keftedes', 'avgolemono', 'saganaki', 'taramasalata', 'kleftiko', 'galaktoboureko', 'tiropita', 'loukoumades', 'revani', 'skordalia', 'fasolada'],
    'Korean': ['bibimbap', 'kimchi', 'bulgogi', 'galbi', 'tteokbokki', 'japchae', 'mandu', 'kimbap', 'samgyeopsal', 'jjigae', 'sundubu', 'pajeon', 'bossam', 'jajangmyeon', 'gamjatang', 'seolleongtang', 'budae jjigae', 'hoeddeok', 'bingsu', 'samgyetang'],
    'Vietnamese': ['pho', 'banh mi', 'spring roll', 'bun cha', 'banh xeo', 'com tam', 'bun bo hue', 'ca kho to', 'cha ca', 'cao lau', 'mi quang', 'hu tieu', 'com chay', 'goi cuon', 'banh cuon', 'com nguoi', 'banh canh', 'bo luc lac', 'thit kho', 'nem nuong'],
    'Spanish': ['paella', 'tapas', 'tortilla', 'gazpacho', 'churros', 'patatas bravas', 'croquetas', 'jamon', 'sangria', 'empanada', 'albondigas', 'pisto', 'fabada', 'pulpo a la gallega', 'calamares', 'pan con tomate', 'chorizo', 'pimientos de padron', 'torrijas', 'horchata']
}

cuisine_adjectives = {
    'Indian': ['spicy', 'creamy', 'aromatic', 'savory', 'tangy', 'hot', 'rich', 'fragrant', 'flavorful', 'traditional'],
    'Mexican': ['spicy', 'zesty', 'fresh', 'tangy', 'fiery', 'savory', 'hearty', 'rich', 'vibrant', 'authentic'],
    'Chinese': ['savory', 'umami', 'stir-fried', 'steamed', 'crispy', 'sweet', 'sour', 'spicy', 'tender', 'aromatic'],
    'Middle Eastern': ['savory', 'aromatic', 'fresh', 'creamy', 'hearty', 'rich', 'smoky', 'spiced', 'tangy', 'warming'],
    'African': ['spicy', 'hearty', 'rich', 'flavorful', 'savory', 'aromatic', 'bold', 'tangy', 'smoky', 'warming'],
    'Thai': ['spicy', 'sweet', 'sour', 'fragrant', 'creamy', 'fresh', 'savory', 'tangy', 'rich', 'aromatic'],
    'Japanese': ['umami', 'savory', 'delicate', 'fresh', 'light', 'balanced', 'traditional', 'rich', 'simple', 'comforting'],
    'Italian': ['savory', 'hearty', 'rich', 'creamy', 'fresh', 'aromatic', 'rustic', 'robust', 'comforting', 'wholesome'],
    'Greek': ['fresh', 'tangy', 'savory', 'rich', 'hearty', 'aromatic', 'light', 'traditional', 'rustic', 'zesty'],
    'Korean': ['spicy', 'fermented', 'savory', 'sweet', 'tangy', 'umami', 'robust', 'rich', 'bold', 'hearty'],
    'Vietnamese': ['fresh', 'aromatic', 'light', 'savory', 'tangy', 'sweet', 'spicy', 'delicate', 'balanced', 'vibrant'],
    'Spanish': ['savory', 'rich', 'smoky', 'aromatic', 'fresh', 'tangy', 'spicy', 'hearty', 'robust', 'comforting']
}

# Helper functions to generate random realistic food data
def generate_protein_name(cuisine):
    proteins = {
        'Indian': ['Chicken', 'Lamb', 'Paneer', 'Fish', 'Shrimp', 'Beef', 'Vegetable'],
        'Mexican': ['Beef', 'Chicken', 'Pork', 'Shrimp', 'Fish', 'Bean', 'Vegetable'],
        'Chinese': ['Chicken', 'Pork', 'Beef', 'Fish', 'Shrimp', 'Tofu', 'Duck'],
        'Middle Eastern': ['Lamb', 'Chicken', 'Beef', 'Falafel', 'Vegetable', 'Fish'],
        'African': ['Chicken', 'Beef', 'Fish', 'Goat', 'Vegetable', 'Bean'],
        'Thai': ['Chicken', 'Shrimp', 'Beef', 'Tofu', 'Fish', 'Pork', 'Vegetable'],
        'Japanese': ['Fish', 'Chicken', 'Beef', 'Tofu', 'Pork', 'Vegetable', 'Seafood'],
        'Italian': ['Beef', 'Chicken', 'Pork', 'Seafood', 'Vegetable', 'Cheese'],
        'Greek': ['Lamb', 'Chicken', 'Fish', 'Beef', 'Vegetable', 'Cheese'],
        'Korean': ['Beef', 'Pork', 'Chicken', 'Tofu', 'Fish', 'Vegetable', 'Seafood'],
        'Vietnamese': ['Beef', 'Chicken', 'Pork', 'Shrimp', 'Fish', 'Tofu', 'Vegetable'],
        'Spanish': ['Pork', 'Chicken', 'Seafood', 'Beef', 'Fish', 'Vegetable', 'Chorizo']
    }
    return random.choice(proteins.get(cuisine, ['Chicken', 'Beef', 'Vegetable']))

def generate_food_name(cuisine):
    ingredient = random.choice(cuisine_ingredients[cuisine])
    adjective = random.choice(cuisine_adjectives[cuisine])
    protein = generate_protein_name(cuisine)
    
    # Different name patterns based on cuisine conventions
    patterns = [
        f'{adjective.capitalize()} {protein} {ingredient.capitalize()}',
        f'{protein} {ingredient.capitalize()}',
        f'{adjective.capitalize()} {ingredient.capitalize()}',
        f'{ingredient.capitalize()} with {protein}',
        f'{cuisine} {protein} {ingredient.capitalize()}',
        f'{cuisine} Style {ingredient.capitalize()}'
    ]
    
    return random.choice(patterns)

def generate_description(cuisine, name):
    # Generate a realistic description based on cuisine and name
    cooking_methods = ['grilled', 'roasted', 'fried', 'sautéed', 'baked', 'steamed', 'stewed', 'braised', 'simmered', 'stir-fried']
    sauces = ['savory sauce', 'rich gravy', 'spicy marinade', 'tangy dressing', 'aromatic broth', 'flavorful seasoning', 'delicate glaze', 'creamy sauce']
    garnishes = ['fresh herbs', 'aromatic spices', 'crunchy vegetables', 'toasted nuts', 'crispy toppings', 'zesty citrus', 'colorful vegetables']
    
    method = random.choice(cooking_methods)
    sauce = random.choice(sauces)
    garnish = random.choice(garnishes)
    
    # Generate description patterns
    patterns = [
        f'{method.capitalize()} dish with {sauce} and {garnish}.',
        f'Traditional {cuisine} dish featuring {name.lower()}, prepared with {sauce}.',
        f'A {method} specialty made with {garnish} and a {sauce}.',
        f'Classic {cuisine} preparation with {garnish}, {method} to perfection.',
        f'Authentic {cuisine} dish with {sauce} and topped with {garnish}.'
    ]
    
    return random.choice(patterns)

# Generate 500 new foods
new_foods = []
next_id = max([int(food['id']) for food in existing_foods]) + 1

cuisine_distribution = {}
for cuisine in cuisines:
    cuisine_distribution[cuisine] = 0

for i in range(500):
    # Choose cuisine, with preference for those with fewer foods
    cuisine = random.choice(cuisines)
    
    # Generate a new food
    food_name = generate_food_name(cuisine)
    
    # Generate realistic nutritional values based on cuisine patterns
    calories = random.randint(150, 650)
    protein = random.randint(5, 40)
    carbs = random.randint(10, 80)
    fat = random.randint(5, 40)
    
    # Ensure calories make sense with macros (rough approximation)
    estimated_calories = protein * 4 + carbs * 4 + fat * 9
    while abs(estimated_calories - calories) > 100:
        # Adjust macros to match calories better
        calories = protein * 4 + carbs * 4 + fat * 9 + random.randint(-50, 50)
    
    food = {
        'id': str(next_id),
        'name': food_name,
        'cuisine': cuisine,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'image': '',
        'description': generate_description(cuisine, food_name)
    }
    
    new_foods.append(food)
    cuisine_distribution[cuisine] += 1
    next_id += 1

# Add the new foods to the existing ones
data['foods'].extend(new_foods)

# Save the updated data back to foods.json
with open('../BreadCrumb/Resources/foods.json', 'w') as f:
    json.dump(data, f, indent=2)

print(f'Added 500 new foods to foods.json')
print('Foods per cuisine:')
for cuisine, count in cuisine_distribution.items():
    print(f'{cuisine}: {count}') 