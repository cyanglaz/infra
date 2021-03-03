#!/usr/bin/env lucicfg
# Copyright 2020 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
"""
Configurations for the plugins repository that listens to new tag changes.
"""

load("//lib/common.star", "common")
load("//lib/repos.star", "repos")

def _setup():
    """Set default configurations for builders, and setup recipes."""
    plugins_define_recipes()
    plugins_tagged_config()

def plugins_define_recipes():
    """Defines recipes for plugins repo."""
    publish_recipe_name = "plugins/plugins_publish"
    for name in recipe_list:
        luci.recipe(
            name =  publish_recipe_name,
            cipd_package =
                "flutter/recipe_bundles/flutter.googlesource.com/recipes",
            cipd_version = "refs/heads/master",
        )

def plugins_tagged_config():
    console_view_name = "plugins_tagged"

    # Defines a list view for try builders
    list_view_name = "plugins-tagged"
    luci.list_view(
        name = list_view_name,
        title = "Plugins tagged builders",
    )

    trigger_name = branch + "-gitiles-trigger-plugins-tagged"

    ref = "refs/tags/.+"

    luci.gitiles_poller(
        name = trigger_name,
        bucket = "prod",
        repo = repos.PLUGINS,
        refs = [ref],
    )

    # Defines plugins Windows platform try builders
    common.linux_prod_builder(
        name = "Linux%s plugin publish" % ("" if branch == "master" else " " + branch),
        recipe = publish_recipe_name,
        console_view_name = console_view_name,
        triggered_by = [trigger_name],
    )

plugins_config = struct(setup = _setup)
