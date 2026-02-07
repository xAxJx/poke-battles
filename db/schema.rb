# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_02_07_090000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "actions", force: :cascade do |t|
    t.bigint "battle_id", null: false
    t.bigint "selected_pokemon_id", null: false
    t.bigint "move_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["battle_id"], name: "index_actions_on_battle_id"
    t.index ["move_id"], name: "index_actions_on_move_id"
    t.index ["selected_pokemon_id"], name: "index_actions_on_selected_pokemon_id"
  end

  create_table "battles", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_battles_on_game_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_games_on_user_id"
  end

  create_table "learned_moves", force: :cascade do |t|
    t.bigint "selected_pokemon_id", null: false
    t.bigint "move_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["move_id"], name: "index_learned_moves_on_move_id"
    t.index ["selected_pokemon_id"], name: "index_learned_moves_on_selected_pokemon_id"
  end

  create_table "moves", force: :cascade do |t|
    t.integer "move_id"
    t.string "name"
    t.string "move_type"
    t.integer "power"
    t.integer "accuracy"
    t.string "damage_class"
    t.text "description"
    t.integer "effect_chance"
    t.text "effect"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pokemons", force: :cascade do |t|
    t.text "name"
    t.integer "number"
    t.string "picture"
    t.string "type1"
    t.string "type2"
    t.integer "hp_max"
    t.string "integer"
    t.integer "hp_current"
    t.integer "attack"
    t.integer "defense"
    t.integer "sp_attack"
    t.integer "sp_defense"
    t.integer "speed"
    t.string "move1"
    t.string "move2"
    t.string "move3"
    t.string "move4"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "selected_pokemons", force: :cascade do |t|
    t.bigint "pokemon_id", null: false
    t.integer "hp_current"
    t.integer "exp"
    t.string "status"
    t.string "ability"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "team_id", null: false
    t.string "move1"
    t.string "move2"
    t.string "move3"
    t.string "move4"
    t.index ["pokemon_id"], name: "index_selected_pokemons_on_pokemon_id"
    t.index ["team_id"], name: "index_selected_pokemons_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "opponent"
    t.bigint "game_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_teams_on_game_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "actions", "battles"
  add_foreign_key "actions", "moves"
  add_foreign_key "actions", "selected_pokemons"
  add_foreign_key "battles", "games"
  add_foreign_key "games", "users"
  add_foreign_key "learned_moves", "moves"
  add_foreign_key "learned_moves", "selected_pokemons"
  add_foreign_key "selected_pokemons", "pokemons"
  add_foreign_key "selected_pokemons", "teams"
  add_foreign_key "teams", "games"
end
