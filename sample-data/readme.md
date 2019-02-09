# Sample Data

Sample glossaries and documents that use them

## Notes about the documents

### The challenges with using glossaries include:

1. Every glossary topic must have an associated key in order to be linked to by term or keyword elements
1. Glossary topics that are to be published in the same publication must be referenced by normal-role topicrefs
1. There is no direct way to have only resource-only topicrefs to glossary entries and then only have those glossary entries that are actually referenced be published (because there's no DITA-defined mechanism for doing that automatically).
1. Having glossary entries published in a separate publication (e.g., a master glossary) with working links requires cross-deliverable linking. The OT as of 3.3 does not implement any cross-deliverable linking features.
1. The OT through 3.3 doesn not properly handle chunking of topicheads, so you can't use topicheads with @chunk to create single result files (in HTML, EPUB, etc.) that contain all the glossary entries for that chunk). This means you must use title-only topics for each letter group or provide custom preprocessing that converts topicheads to title-only topics for glossary groups.
1. The OT does not provide out-of-the-box glossary sorting, grouping, or generation.
1. The glossref element sets @print, @toc, and @search to "no", so it's not very useful. Don't use it.

### Some techniques that can be useful:

* Put the glossary resource-only keys in a key scope so that the resource-only key names and the normal-role key names can be the same. This makes it easier to use one set of keys or the other depending on the details of how the maps are structured.
* Put the normal-role glossary entries also in a key scope, e.g. "gloss" or "glossary" so that you don't have to worry about name conflicts between glossary keys and any other keys in the publication.

### Aikido publications

The Aikido docs include a complete English glossary of Aikido terms. Each glossary entry is a separate glossentry topic. The letter groups are glossgroup title-only topics, as is the top-level glossary title topic.

There is a resource-key-defining map, `aikido-master-glossary-keydefs.ditamap`, that defines a resource-only key for each glossary entry.

There is a normal-role glossary map

## DITA OT Notes

* PDF2 transform through 3.2.1 has a bug that causes processing to fail if there are two levels of indirection for a topicref (topicref that uses a keyref to refer a keydef). This bug is fixed in 3.3.

