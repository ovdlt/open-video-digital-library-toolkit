Open Video Digital Library Toolkit
==================================

Information about the project, etc.

Coding Standard
===============

Generally the project coding standard follows [Ruby Garden](http://www.rubygarden.org/Ruby/page/show/RubyStyleGuide) (the below is pretty much a copy/paste from there)

Naming Conventions
------------------

* `CONSTANTS_USE_UPPER_CASE` -- for example: `Math::PI`, `Curses::KEY_DOWN`, `OptionParser::REQUIRED_ARGUMENT`
* `ClassesUsePascalCase` -- join words of class names by capitalizing the first letter of each word. The same goes for `ModuleNames` as well.
* methods use underscores, as do `local_variables`, `@instance_variables`, and `@@class_variables` -- join words with underscores (aka `snake_case`) 
* Keep acronyms in class names capitalized. `MyXMLClass`, not `MyXmlClass`. Variables should use all lower-case. 

There is no place in Ruby where camelCase is ever used.

Formatting Conventions
----------------------

Method Parameters:

* put parentheses around non-trivial parameter lists
* don't put spaces between a method name and its parameter list 

Whitespace Conventions
----------------------

* Use two spaces for indentation
  - Tabs versus spaces is a matter of personal preference when editing, but the community generally agrees that two-spaces is how you should release all your code. Space indentation outnumbers tab indentation more than 10:1 in the source code. 

{ ... } blocks versus do ... end blocks
---------------------------------------
Use curly braces for one-line blocks, use do...end for multi-line blocks

