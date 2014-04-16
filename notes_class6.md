(review of previous weeks)
When the internet just emerged, primary paradigm for service was like the basic TCP server!

Today: user systems and application security

cp database.rb live_coding.rb
require './live_coding'

right now, have sqlite database, executing SQL commands to interact with it

look at database, have journal_entries table and index table
we want the surfing journal to be a user blog - create your own journal
sqlite3 live_coding.db

>CREATE TABLE users(
	id INTEGER PRIMARY KEY,
	name VARCHAR(256),
	username VARCHAR(256),
	password VARCHAR(256)
	);

> .schema
# yep, user table is there
> INSERT INTO users(name, username, password) VALUES('john doe', 'john', 'foo')
> INSERT INTO users(name, username, password) VALUES('mary doe', 'mary', 'bar')
> SELECT * from users;
> ALTER TABLE users ADD COLUMN id INTEGER;
> UPDATE users SET id = '1' WHERE username = 'john'

ok, we made users.
foreign keys and associations
create association with users

> ALTER TABLE journal_entries ADD COLUMN user_id INTEGER;
> UPDATE journal_entries SET user_id = '1' WHERE id = '1' 
> UPDATE journal_entries SET user_id = '2' WHERE id = '2'
Oops, forgot to set primary key. No auto-indexing, no automatic insertion
Cannot really update a column in SQlite3
(regenerate table quickly using history)
put an index on the foreign key column
> CREATE INDEX journal_entries_user_id_index ON journal_entries (user_id)

Now we want to show only the journal entries that are John's. (woo!)
/?
user_id = request.params["user_id"]
@journal_entries = @db.execute "SELECT * FROM journal_entries WHERE user_id='#{user_id}'"

obviously not workable, though!
username, password = request.params['username'], request.params['password']
user = (db.execute "SELECT * FROM users where username='#{username} AND password ='#{password}'").first
user_id = user['id']
@journal_entries = @db.execute "SELECT * FROM journal_entries WHERE user_id = '#{id}"

issues: bad password = explodes

if user

else
	[401, {}, ["Wrong username and password."]]
end

issue - obviously, typing in this stuff is bad
want to protect link, need to authenticate
now the user has to submit everything together
can't make the links include everything - bad idea
need a better auth mechanism
this is where cookies come in! yay!
assume entry point is main page
session - hash, bunch of key-value pairs

if user 
	session {user_id: user_id}

where do we want to keep the hash? could do an in-memory database
easies thing is cookies
resources Chrome 
cookies - no cookies right now

if user
	(render code added to end)
	[200, {"Set-Cookie" => user_id }, [document]]

now there's a cookie, set value to 1, no name for it
cookies have their own syntax
can set expires, max age, domain, path, http only
Max-Age: in seconds  
Expires: pass in a date (session: gone when close browser)

All browsers support cookies. Automatically expires cookies for you
"Set-Cookie" => "user_id=1"

now in the show method:
	if user_id = request.cookies["user_id"]
		user = @db.execute()

curl -I http://localhost:9292/\?username\=john&password\=foo
sends the request cookie

now sessions
we have a static sign-in page 
form action="/new_session" method="post"

elsif request.post? && requst.path == "/new_session"
	username, password = request.params['username'], request.params['password']
	user = (db.execute "SELECT * FROM users where username='#{username} AND password ='#{password}'").first
	if user
		session = {user_id: user['id'], name: user['name']}
		[302, {"Set-Cookie" => "app_session=#{Marshal.dump(session)}", "location" => '/'}, []]
	else 
		[401, {}, "Wrong username and password."]

serialize: convert hash into string
the wire only understands strings
can serialize into a YAML, JSON, or Marshal file
Marshal.dump(_)
Marshal.load("#{dumpoutputhere}")

session = request.cookies['app_session']
if session
	user_id = session[:user_id]
	etc.

oops, invalid header value!
http protocol has specific requirements
there are illegal characters in our string
Base64 encoding - translates any binary data into purely printable characters
Base64.encode64(Marshal output here)

"app_session = Base64.encode64(etc.)"

'require Base64' - included with ruby, must be required
So, what's wrong with this? Now I can say I'm somebody else, just using Marshal and Base64!
This is called cookie tampering
You need something secret
Under config/initializers there's a secret_token.rb
add the secret after Marshal dump
when encode, can't just get session back out of it

session = Marshal.load(Base64.decode64)
rails rake secret.new (?)

@data = {name: session[:name]}

sign out 
elsif request.get? && request.path == '/logout'
	session = Marshal.load(etc.)
	session[:user_id] = nil
			[302, {"Set-Cookie" => "app_session=#{Marshal.dump(session)}", "location" => '/'}, []]

back at '/'
if session && sesion[:user_id]
	session = etc if request.cookies['app-session']
else
	redirect 'site/sign_in.html'

cookie is still there... but user_id is gone

authentication
could do if/else for each path, but it's repeating a lot of code

use blocks to extract

def authenticate(request, &block)
	session = 
	if session
		yield(user_id) #or block.call(user_id)
	else
end

authenticate do |user_id|

end

(adjustments to SQL to lock down)

registering

elsif request.post? && request.path == '/register'
	username, password, name = request.params['username'], request.params['password'], request.params['name']
	@db.execute "INSERT INTO users (username, password, name)" VALUES('#{username}', '#{password}', '#{name}')"
	redirect_to '/'

passwords as plaintext, bleah
don't ever, ever store passwords that way
encrypt the password
digest SHA1

in create_user
encrypted_password = Digest::SHA1.hexdigest(password)

require 'Digest'
one-way encryption, can't get back to original password
can't revert, but well-known hash algorithm
salt password
add a new column called salt
salt = SecureRandom.hex(8)
Digest::SHA1.hexdigest(password+salt)
salt is new column in db

if user ['password'] == Digest::SHA1.hexdigest(password + user['salt'])