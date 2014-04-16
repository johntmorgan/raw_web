Now, using databases instead of CSV files to manage server-side state

Move all data to database
Right now, two CSV files
Create DB file

sqlite3 - use locally as engine - light weight DB
supports most of the standard SQL commands
tutorialspoint.com/sqlite
note that caps are convention

$sqlite3 surfing.db
>CREATE TABLE journal_entries (
	id INTEGER PRIMARY KEY,
	title VARCHAR(256),
	description TEXT
	)
;

VARCHAR - variable length characters, length
>.schema

Now start inserting records

INSERT INTO journal_entries(id, title, description) VALUES (1, 'Huge Waves!', 'Windy day, huge waves, I lost my board.');

SELECT id, title, description from journal_entries;

INSERT INTO journal_entries(id, title, description) VALUES (2, 'I saw a shark', 'I was so excited')

INSERT INTO journal_entries(id, title, description) VALUES (2, 'Good coffee', 'Kept me awake')

* means select all columns
SELECT * from journal_entries;

SELECT * from journal_entries WHERE id=1;
SELECT * from journal_entries ORDER BY id;

UPDATE journal_entries SET title='Bad Coffee', description='I did not drink it' WHERE id=3;

.exit

Right now, directly inside db. Move all storage to database. Databases only speak SQL.

delete.rb
cp database.rb database_original.rb (solution)

cp delete.rb database.rb

get rid of require 'CSV'
require 'sqlite3' # gem, sqlite-ruby

if get('/', request)
	#open database
	db = SQLite3::Database.new "data/surfing.db"
	db.execute "SELECT * FROM journal_entries"
	binding.pry

Data is array of arrays. What you want is a hash
Easy way to do it 
	db.results_as_hash

move DB open to initialize
specify ID as primary key - generates automatically off of highest value

INSERT INTO journal_entries(title, description) VALUES ("#{request.params["title"]}")

Searching
still have search term (request.params["search_word"])
# database engine specialized for searches, etc.
# push down this function for max performance as much as you can
@db.execute "SELECT * FROM journal_entries WHERE title LIKE '%#{}%' OR description LIKE ''

% - wildcard before or after 

SQL injection - store into database - everything translated into SQL commands - must assume not safe, malicious user

entry_id = "1; DELETE FROM journal_entries id=1"

db.execute("INSERT INTO students (name, email, grade, blog) VALUES (?, ?, ?, ?)", [@name, @email, @grade, @blog]

>ALTER TABLE journal_entries ADD COLUMN posted_at DATETIME;


INSERT INTO journal entries (title, description, posted_at)

'#{Time.now}'

Another high-level concept:
Index
retrieve records by title
If we have a million records - look at each in turn
Create an index based on title column
Makes search quick - but have to update index every time

CREATE INDEX title_index ON journal_entries (title);

In rails, do this in migrations
add_index table_name, [user_id]

You don't want to index everything, only the columns you query a lot. Foreign keys are commonly queried - lowest hanging fruit for performance tuning

99% read, 1% write - index much more aggressively
Always index your foreign keys!

First thing with performance - monitoring - see bottlenecks

Unique Index
CREATE UNIQUE INDEX index_name
on table_name (column_name);

rejects record if try to create another record with same column value

next, sessions, cookies, and authentication