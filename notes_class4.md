Just got to the end of refactor.rb
On Rack.

Right now, we have the data in the same file as the code.
No way to do persistence. When the server goes off, the data is gone.
Easiest way to do it? Just the file system. Sometimes, could even be the right tool for the job!
(Will discuss what it is and isn't good for later)
Moved data into CSV file, journal_entries.rb

def read_journal_entries
	entries = CSV.read("data/journal_entries.csv")
	entries.reduce([]) do |result, entry|
		result << {title: entry[0], description entry[1]}
	end
end

**look at reduce, similar to inject
Ok, works.

Writing to CSV file?

call write_journal_entries(request.params)

# adds to the *bottom* of the page
def write_journal_entries(entry)
	# a for append mode
	CSV.open("data/journal_entries.csv", "a") do |csv|
		csv << [entry['title'], entry['description']]
	end
end

Add index to entries so they can be ordered
index_data.rb
2,article,title
1,article,title

Still limited - schema is not clear. What is each column? What is its data type? Can guess from the data, but....

initialize removed from file now. Read every time you hit '/'
result << {index: entry[0]}
result.sort_by{|hash| hash[:index]}.reverse

def write_journal_entries
	csv << [journal_entry_count + 1, etc]
end

def journal_entry_count
	CSV.read("data/journal_entries.csv").count
end

Now, there are some problems.
Have to open the entire file and scan it every time you add an entry. That's a lot of reads. Load & reload CSV file.

Keep an in-memory version of this file.
Memoize.rb

#set if not set already
if get('/', request)
	@journal_entries ||= read_journal_entries

add to write journal entries:
	@journal_entries = nil

Searching
Form, method get so it shows up in URL, Google style
found_entries = @journal_entries.select{ |entry| entry[:title].include?(search_term) || entry[:description].include?(search_term) }
@data = {journal_entries: found_entries}
render

Retrieval
<a href="/journal_entries{{/index}}">{{title}}</a>

Show single entry
Template that does it.
Tricky: route. All routes so far are deterministic
Need to match a pattern - use regex
capture using (.*) inside regex

^ begin string
\/ escaped slash
.* whatever, anything
$ end string

elsif request.get? && request.path =~ /^\/journal_entries\/.*$/
	# parentheses capture what comes after, match 1
	entry_id = (/^\/journal_entries\/(.*)$/.match(request.path))[1]
	# could be duplicates, can't rely on this code in high traffic system
	# (multiple servers, concurrent submissions)
	# relational databases ensure integrity - next class!
	selected_entry = @journal_entries.select { |entry| entry[:index] == entry.id }.first
	@data = {journal_entry: selected_entry}
	render :show

Deletion
delete.rb
How to do?
# my idea
POST
/delete_journal_entry/2
<form action "/journal_entries/{{index}}", method="post">
	<input type="hidden" name="method" value="delete">
	<input type="submit" value="Delete">
</form>

elsif request.post? && request.path =~ /^\/journal_entries\/.*$/ && request.params['method'] == 'delete'
	entry_id = (^\/journal_entries\/(.*)$).match(request.path))[1]
	@journal_entries.delete_if { |entry| entry[:index] == entry_id }
	save_journal_entries(@journal_entries)
	redirect_to '/'

def save_journal_entries(entries)
	CSV.open("data/journal_entries.csv", "w") do |csv|
		csv = entries
	end
	@journal_entries = nil
end

Updating (very similar!) - kinda skip - match, populate form with value of record, when you submit, hidden method 'put'

Those fill in 7 main actions of Rails.

Considerations & tradeoffs
For databases - a lot of this is handled by underlying system - don't have to make most of these decisions.
But a CSV, sequential access data store:
- How do we optimize for show all?
	Caching - @journal_entries - we already did this
	Not what you want to do if there's, say, 10k entries!
- Optimize for single read?
	Cache single entries - easy to get
	Tradeoff is memory space vs I/O - read CSV & find
	More in memory, less disk hits 
	Good trade, memory on Moore's law, disks not getting much faster, even with SSD
- Optimize for writing?
	Say 50% of the access is creating new journal entries (dropbox-like system? cloud storage?)
	Easiest way to write is to append - do what we do today
	Tradeoff is that it's really easy to insert, but entries are not sorted
	When you do show all, you have to load *and order* everything in memory
- Optimize for search?
	Start with show all optimization - have all records in memory
	Cache search keyword with results

Tradeoffs
- Space vs. IO vs. computation
	More memory space, save on IO (most expensive), computation (somewhat expensive)
- Consistency vs. speed/availability
	Need to constantly rebuild index - 10m, 1hr, 1/2 day?
	Either not available or not consistent during this time
	More updates = more consistent with current, less available
	Account balance = very important to be consistent!
	Journal entries = not so important!

MongoDB - specific optimization (document driven)
Relational DB - optimize for other things

Relational DB more consistent, enforce data integrity
Document DB easy to access and retrieve

Next, databases, and smart things to make routing look better
