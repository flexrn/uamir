# UAMiR (**U**niversal **A**ssignment **M**anager in **R**uby)

This gem provides an interface to the Universal Assignment Manager associated with API Healthcare's Contingent Staffing/Recruiting Solution.


## Installation

Add this line to your application's Gemfile:

    gem 'uamir'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install uamir


## Recruiting Solution Documents, UAM Requests, and Admin information

Before using most of the features of the assignment manager you have to understand the anatomy of a Recruiting Solution document.

Recruiting solution documents have several fields roughly described by the following
TODO: Describe document format

A request is any document that has been assigned; this is equivalent to the items already present in the assignment manager.

The request has several fields
* *adminusername*: the username of the individual that initially created the request. 
* *assigned*: boolean, 1 or 0. For existing assignments this is always 1.
* *assignedby*: username of user that assigned the document.
* *assignmentid*: unique assignment id for the request. This is used for `Flexrn::Uam::AssignmentManager#sendreminder`.
* *credentialname*: the name of the credential as it appears in the assignment manager.
* *dateassigned*: The date/time the document was assigned, in the format "MM/DD/YY HH:MM AM/PM"
* *firstname*: the first name of the individual the request is assigned to.
* *lastname*: the last name of the individual the request is assigned to.
* *remindedby*: the username of the user that sent the last reminder. If a reminder has not been sent this has a value of "System".
* *remindersent*: the date/time the last reminder was sent for the 
* *rsscredid*: integer id of the rss document associated with the request.
* *type*: String type of the rss document associated with the request.
* *username*: the username of the individual the document is assigned to; typically the email address.
* *versionid*: the versionid of the rss document; when the rss document does not have a versionid this is a blank string.


## Usage

### Initializing client
TODO: Explanation of initialization arguments, site name, rss site name, etc.
TODO: Example

The Universal Assignment Manager allows the following actions:
### Document assignment

TODO: Explanation
TODO: Example

### Retrieve documents assigned

TODO: Explanation
TODO: Example

### Request reminders

TODO: Explanation
TODO: Example

### Request deletion

TODO: Explanation
TODO: Example


## Contributing

1. Fork it ( https://github.com/[my-github-username]/uamir/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
