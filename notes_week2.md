Last week - by the end, able to serve up static pages from directory /site

Today dynamic pages
Templating engine: mustache - logic-less templates in a tone of languages. (mustache.github.io)

gem install mustache
irb
>require 'mustache'
input template, data
Mustache.render("My name is {{name}}", name)

Anyway
$cp server_on_rak.rb template.rb

Want / to render main page - not just static html, but separate data in templates

$mkdir templates

cp ../site/index.html index.mustache

Currently, the data is embedded directly in the file. Not good! 

{{#journal_entries}}
	(formatting)
	{{title}}
	{{description}}}
{{/journal_entries}}

{{#water_conditions}}
	(formatting)
	{{date}}
	{{description}}
{{/#water_conditions}}

require 'mustache'
class SurfCarmel
	def initialize
	  @journal_entries = journal_entries
	  @water_conditions = water_conditions
	end
	if env['REQUEST_PATH'] == '/'
	  front_page_data = {'journal_entries' => @journal_entries, 'water_conditions => @water_conditions'}
	  content = Mustache.render(File.read('templates/index.mustache'), front_page_data)
	  [200, {}, [content]]
	else
	  (render static page code)
	end
def journal_entries
  [{title: "A look back: huge waves!", 
  	description: "blah blah enormous text file"
	}, {title: "Second title",
	description: "second description"},
	{title: "third title", description: "another description"}
	]
end

def water_conditions
	[{date: 'Februrary 19, 2014', description: 'toegnar waves!'},
	{date: 'another date', description: 'another description'}]
end

Note on how we'd do those huge descriptions, with lots of quotes:
#HEREDOC: 
<--DESCRIPTION
	Everything in here is treated as a string, regardless of quotes!
DESCRIPTION

run rackup

Boom, it's up! Looks the same, even though we've separated the data out into a template
Meaning of the word render - is always to take a template and take some data and use those to make a final html page.

Under the hood, mustache loops through areas linked by {{#}}, {{/}} and pulls out values linked to keys ided with {{key}}

Now: accepting data from user inputs
Wait, not next. First, actual greeting

pry, look at header
if you do ?name=stefano
QUERY_STRING=>"name=stefano"

Step back and look at different parts of URL
https://www.gotealeaf.com:80/sign_in?name=stefano#bookmark1
https - protocol
www.gotealeaf.com - domain
80 - port, default is 80
sign_in - path
?blah - query paramters/strings
# - fragments

http://doepud.co.uk/images/blogs/complex_url.png

now using utility 
request = Rack::Request.new(env)
pry 
>cd request
>ls

front_page_data = {'user_name' => request.params['name']}
insert {{user_name}} on template

Forms
site directory
touch new_journal_entry.html

elsif request.path == '/create_journal_entry'
  new_entry = {title: request.params['title'], description: request.params['description']}
  @journal_entries.unshift(new_entry)
  front_page_data = {'journal_entries' => @journal_entries, 'water_conditions => @water_conditions'}
  content = Mustache.render(File.read('templates/index.mustache'), front_page_data)
  [200, {}, [content]]


basic html form - default action is a get request
data is encoded into url, this encoding is default
<form enctype="application/x-www-form-application">
URI.encode("I had a great day!")
URI.decode(output of URI.encode)
URI.encode_www_form({"title"=>"I had a great day!"})

Anyway that works, but now the URL is huge and messy! Strongly not encouraged. Right way is to use POST. GET is for getting resources, idempotent - doesn't change server state
data is now in the body, in variable @input.

pry
>cd body
>@input.read

request.params extracts that from the body

Because it's a post, we're submitting data, not requesting it. 
What should the server do? The client isn't asking the server to do anything.
This is why we do redirects after posts. For get, you're handing back a document or rendering a template. 

elsif request.post? && request.path == '/create_journal_entry'
  [302, {'Location' => '/'}, ['302 found']] #last bit doesn't matter for browser (will see on HTTP client)

Rack is not a server, but a specification. Ruby servers implement the web interface. WEBrick, Thin, Rainbows
WEBrick, but to put on thin, don't need any additional code changes - neat! 

Of course, can obviously move repeated code off into render function
render 'index', front_page_data

redirect_to(path)
[302, {'Location: #{path}'}, ['302 found']]
Next week: capturing server state