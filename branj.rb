#!/usr/bin/env ruby
require "uri"
require "net/http"
require "base64"
require "json"

# Requires user to define the following in their environment:
# export JIRA_USER='someone@acmeco.com'
# export JIRA_TOKEN='xxxxxxxxxxxx'
# export JIRA_ROOT_URL='https://acme-co.atlassian.net'

class Branj
  def perform
    `git checkout -b #{branch_name}`
  end

  private

  def jira_issue_key
    ARGV[0]
  end

  def fetch_ticket_name_from_jira
    url = URI(jira_issue_url(jira_issue_key))

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["Authorization"] = "Basic #{authorization_string}"

    response = https.request(request)
    case response.code.to_i
    when 200
      result = JSON.parse(response.read_body)
      result["fields"]["summary"]
    when 403, 404
      result = JSON.parse(response.read_body)
      raise StandardError.new(result["errorMessages"].join("\n"))
    else
      raise StandardError.new("#{response.code}: #{response.read_body}")
    end
  end

  def jira_issue_url(key)
    "#{jira_root_url}/rest/api/3/issue/#{key}?fields=summary"
  end

  def authorization_string
    Base64.strict_encode64("#{jira_username}:#{jira_token}")
  end

  def branch_name
    "#{jira_issue_key}-#{simplified_issue_summary}"
  end

  def simplified_issue_summary
    issue_summary = fetch_ticket_name_from_jira
    # Limit the number of characters through truncation
    issue_summary = issue_summary[0..50]
    # Lower case letters only
    issue_summary = issue_summary.downcase
    # Replace any occurences of special characters with dashes ([a-z0-9_] remain)
    issue_summary = issue_summary.gsub(/[^\w]+/,"-")
    # Do not start with dash
    issue_summary = issue_summary[1..issue_summary.length] if issue_summary[0] == "-"
    # Do not end with dash
    issue_summary = issue_summary[0..issue_summary.length-2] if issue_summary[issue_summary.length-1] == "-"
    issue_summary
  end

  def jira_username
    raise "Environment variable JIRA_USER is undefined. This is the e-mail you sign into Jira with" if ENV["JIRA_USER"].nil?
    ENV["JIRA_USER"]
  end

  def jira_token
    raise "Environment variable JIRA_TOKEN is undefined. You can get this from https://id.atlassian.com/manage-profile/security/api-tokens" if ENV["JIRA_TOKEN"].nil?
    ENV["JIRA_TOKEN"]
  end

  def jira_root_url
    raise "Environment variable JIRA_ROOT_URL is undefined. This should be something like 'https://acme-co.atlassian.net'" if ENV["JIRA_ROOT_URL"].nil?
    ENV["JIRA_ROOT_URL"]
  end
end

Branj.new.perform
