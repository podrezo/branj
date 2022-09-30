# branj

Automatically generate and check out a git branch based on a Jira issue summary. Inspired by [nulogy/branj](https://github.com/nulogy/branj), originally written by [@ryandv](https://github.com/ryandv).

For example, let's say you have a Jira ticket with key `ABC-123` and summary "[P0] Do the thing!":

```shell
(master) $ branj ABC-123
Switched to a new branch 'ABC-123-p0-do-the-thing'
(ABC-123-p0-do-the-thing) $
```

## Installing

Requires Ruby as a prerequisite.

```shell
git clone git@github.com:podrezo/branj.git
cd branj
mkdir ~/bin
echo 'export PATH=~/bin:$PATH' >> ~/.zshrc
source ~/.zshrc
ln -s "$(pwd)/branj.rb" ~/bin/branj
```

Also, add the following to your environment variables in your RC file:

```shell
export JIRA_USER='someone@acmeco.com'
export JIRA_TOKEN='xxxxxxxxxxxx'
export JIRA_ROOT_URL='https://acme-co.atlassian.net'
```

You can generate the token here: https://id.atlassian.com/manage-profile/security/api-tokens

## Usage

Just pass the ticket key as the first parameter to the `branj` command:

```shell
branj ABC-123
```

## Contributing

Pull requests are welcome!
