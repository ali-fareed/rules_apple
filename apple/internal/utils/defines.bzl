# Copyright 2018 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Support functions for common --define operations."""

def _bool_value(ctx, define_name, default):
    """Looks up a define on ctx for a boolean value.

    Will also report an error if the value is not a supported value.

    Args:
      ctx: A skylark context.
      define_name: The name of the define to look up.
      default: The value to return if the define isn't found.

    Returns:
      True/False or the default value if the define wasn't found.
    """
    value = ctx.var.get(define_name, None)
    if value != None:
        if value.lower() in ("true", "yes", "1"):
            return True
        if value.lower() in ("false", "no", "0"):
            return False
        fail("Valid values for --define={} are: true|yes|1 or false|no|0.".format(
            define_name,
        ))
    return default

def _string_value(ctx, define_name):
    """Looks up a define on ctx for a string value.

    Will also report an error if the value is not defined.

    Args:
      ctx: A skylark context.
      define_name: The name of the define to look up.

    Returns:
      The value of the define.
    """
    value = ctx.var.get(define_name, None)
    if value != None:
        return value
    fail("Expected value for --define={} was not found".format(
        define_name,
    ))

def _resolve_string(ctx, string):
    """Resolves a string value for a define if necessary

    Args:
      ctx: A skylark context.
      string: The name of the define to look up or a string constant.

    Returns:
      The value of the define if string is formatted like {key}, unmodified string otherwise.
    """
    pattern_start = string.find("{")
    pattern_end = string.find("}")
    if pattern_start != -1 and pattern_end != -1 and pattern_end > pattern_start:
      pattern_value = string[(pattern_start + 1):pattern_end]
      resolved_value = _string_value(
        ctx,
        pattern_value,
      )
      result_string = string[:pattern_start] + resolved_value + string[pattern_end + 1:]
      return result_string
    return string

defines = struct(
    bool_value = _bool_value,
    resolve_string = _resolve_string,
)
