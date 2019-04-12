# Using Code Templates in oXygen

### Summary
Code templates are a feature of oXygen that allow snippets of XML to be inserted easily into topics, in both Author and Text mode. These snippets can contain variables or prompt for information when being inserted.

## Installing a new code template

1. Open the oXygen preferences.
1. Type *code template* , in the text filter box to easily locate the Code Template preferences.
   The path is **Editor > Content Completion > Code Templates**  
1. Click Import to start the import process. 
   When the template is imported, a confirmation dialog appears.

Repeat these steps for each code template. 

Note: Ensure Content Completion is eabled. It is enabled by default, but if you disabled Content Completion, you must reenable it to use Code Templates.

## About each Code Template

There are three Code Templates provided. 

- glossary - ask key
- glossary - selection key
- xref href - ask href

### glossary - ask key
This code template requests manual input for key references. This is useful in those cases where you may have a key that is assigned that differs from the name. 

### glossary - selection key
This code template uses the highlighted word for the key reference. Useful if you only have a few terms you need to mark up.

### xref href - ask key
This code template was designed for those situations where your glossary is available already online. In this case, the term really is an xref to the online term.

## Using a code template in oXygen

Code templates are used inside oXygen by using the key combination of ***control-space*** in the author view, or ***control-shift-space*** in the text view.
