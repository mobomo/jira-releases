# Jira Releases

[![CircleCI Build Status](https://circleci.com/gh/mobomo/jira-releases.svg?style=shield "CircleCI Build Status")](https://circleci.com/gh/mobomo/jira-releases) [![CircleCI Orb Version](https://badges.circleci.com/orbs/mobomo/jira-releases.svg)](https://circleci.com/orbs/registry/orb/mobomo/jira-releases) [![GitHub License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/mobomo/jira-releases/master/LICENSE) [![CircleCI Community](https://img.shields.io/badge/community-CircleCI%20Discuss-343434.svg)](https://discuss.circleci.com/c/ecosystem/orbs)

This Orb helps you creating and releasing your Jira project versions.


**NOTE:** To avoid setting the auth token in your config files, you must define it as an CircleCI Environment Variable.

Using the CircleCI UI, you can go to your Project > Project Settings > Environment Values > Add Environment Value called
`JIRA_AUTH`

In order to encode the username:password string, you can run:
```shell
echo -n 'jira_user_email:jira_api_token' | openssl base64
```

Copy the base64 encoded string and paste it in the Environment Variable `Value` field:

![Setting CircleCI Env Vars](assets/cci_env_vars.png)
