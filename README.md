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

Recruiting solution **documents** have several fields roughly described by the following:

* *name*: the name of the document as it appears in Recruiting Solution.
* *rsscredid*: the unique id of the document.
* *type*: the type of the document. May be one of:
  * *Skills*: skills checklist
  * *Docs*: documents that have been added by the company
  * *Tests*: online tests
* *versionid*: the version number; seems only to apply to tests.

Don't rely on the name to uniquely identify a document, as it's possible to delete and create another document with the same name.

A **request** is any document that has been assigned; this is equivalent to the items already present in the assignment manager, and corresponds to the values present in the returned hashes from UAMiR::AssignmentManager#get_assigned_documents.

The request has several fields:

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

To make an assignment you need the Recruiting Solution and Contingent Staffing sitenames for the company, along with the id of an administrative user with privilege to assign documents.

    # Subsititute the values below with your own
    RSSURL = 'rss_sitename'
    TSSURL = 'tss_sitename'
    RSSUSERID = 0

    client = UAMiR::AssignmentManager.new(RSSURL, TSSURL, RSSUSERID)

### Document assignment

TODO: Explanation
TODO: Example

### Retrieve documents assigned

You can retrieve an array of hashes (as described in the requests above) using the UAMiR::AssignmentManager#get_assigned_documents method. The `candidate_id` is the id corresponding to the candidate in Recruiting Solution. For an individual this can be retrieved from the URL of the candidate page in Recruiting Solution. Retrieval:

    client = UAMiR::AssignmentManager.new(RSSURL, TSSURL, RSSUSERID)
    candidate_id = 2000
    docs = client.get_assigned_documents(candidate_id)

which will return an array of hashes with string keys representing the assignments made to an individual.

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
