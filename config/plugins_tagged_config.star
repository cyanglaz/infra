#!/usr/bin/env lucicfg
# Copyright 2020 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
"""
Configurations for the plugins repository that listens to any tag changes.
"""

load("//lib/common.star", "common")
load("//lib/repos.star", "repos")

def _setup():
    """Set default configurations for builders, and setup recipes."""
    plugins_define_recipes()
    plugins_tagged_config_setup()

def plugins_define_recipes():
    """Defines recipes for plugins repo."""
    publish_recipe_name = "plugins/plugins_publish"
    luci.recipe(
        name = publish_recipe_name,
        cipd_package =
            "flutter/recipe_bundles/flutter.googlesource.com/recipes",
        cipd_version = "refs/heads/master",
    )

def plugins_tagged_config_setup():
    """Detailed builder configures."""

    # Defines a list view for builders
    list_view_name = "plugins-tagged"
    luci.list_view(
        name = list_view_name,
        title = "Plugins tagged builders",
    )

    trigger_name = "-gitiles-trigger-plugins-tagged"
    ref = "refs/tags/.+"

    # poll for any tags change
    luci.gitiles_poller(
        name = trigger_name,
        bucket = "prod",
        repo = repos.PLUGINS,
        refs = [ref],
    )

    triggering_policy = scheduler.greedy_batching(
        max_batch_size = 20,
        max_concurrent_invocations = 1,
    )

    console_view_name = "plugins_tagged"
    luci.console_view(
        name = console_view_name,
        repo = repos.PLUGINS,
        refs = [ref],
    )

    publish_recipe_name = "plugins/plugins_publish"

    # Defines builders
    common.linux_prod_builder(
        name = "plugin publish|publish",
        recipe = publish_recipe_name,
        console_view_name = console_view_name,
        triggered_by = [trigger_name],
        triggering_policy = triggering_policy,
    )

plugins_tagged_config = struct(setup = _setup)
