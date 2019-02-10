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

There is a resource-key-defining map, `aikido-master-glossary-keydefs-en.ditamap`, that defines a resource-only key for each glossary entry.

There is a normal-role glossary map, `aikido-glossary-navigation-en.ditamap` that uses keyrefs to refer to the resource-only keys.

The resource-only map is in the key scope "gloss-res" (glossary resource-only keydefs) so all the references from the navigation map to the resource-only keys are qualified with the key scope:

```
         <topicref keys="aihanmi" keyref="gloss-res.aihanmi"/>
```

With both of these maps the base keys are the same are just the terms with "-" for spaces.

This allows the key references within the glossary topics to other glossary entries to just use the base key:

```
<glossentry id="Daito-ryu">
  <glossterm>Daito ryu</glossterm>
  <glossdef> 
      <term keyref="aikijutsu"/> school
</glossdef>
</glossentry>
```

Because all the glossary entries are within the same key scope, there is no need to scope-qualify the key references to other glossary entries. This also means that the term links will point to the appropriate (scope-specific) use of the target glossary entry. 

This is important when branch filtering or other key scope tricks are in effect such that the key reference might end up pointing to a different topic or to a topic that has different effective content based on the filtering and scope-specific key definitions in effect for a given use of the glossary entry. Those cases do not occur in this content set yet, but the Aikido content set has been set up with content targeted to either beginner or expert practitioners, so you can imagine glossary entries that have more or less detail depending on the target audience published from a single set of glossary topics with content conditioned on audience.

The glossary terms are used from technique descriptions in order to both reflect the term text and, where possible, create links to the definitions:

```
<shortdesc>Breath power (<term keyref="glossary.kokyu"/>) throw or exercise (<term
      keyref="glossary.ho-1">ho</term>) from kneeling position (<term keyref="glossary.seiza"
      >seiza</term>)</shortdesc>
```

Note the scope qualification "glossary." on all the keyrefs.

The requirement established here by the way the keys and scopes have been set up is that there must be a key scope named "glossary" that provides the glossary entries or their functional equivalent.

For the Intro To Aikido publication there are three different root maps, each map reflecting a different glossary configuration option:

1. The `intro-to-aikido-bookmap-literal-glossary.ditamap` uses the glossary navigation map and thus has a statically-defined navigation structure for the glossary: 
```
  <backmatter>
    <booklists>
      <glossarylist href="glossary/aikido-glossary-navigation-en.ditamap"
        keyscope="glossary"
        format="ditamap"/>
    </booklists>
  </backmatter>
```
It uses the bookmap map type so that it has the bookmap-specific &lt;glossarylist&gt; element available. This is not strictly necessary with a statically-defined glossary but it is useful as it might enable glossary-specific formatting and it makes this map parallel with the other map that uses &lt;glossarylist&gt; to generate the glossary.
1. The `intro-to-aikido-bookmap-generated-glossary.ditamap` uses empty &lt;glossarylist&gt; to signal generation of the glossary based on some criteria, such as the terms actually referenced from the non-glossary-topics used directly from the map and the glossary topics referenced by the directly-used glossary topics:
```
 <backmatter>
    <booklists>
      <glossarylist/>
    </booklists>
  </backmatter>
```
1. The `intro-to-aikido-bookmap-cross-book-link-to-glossary.ditamap` uses the glossary as a separate publication. It points to the standalone master glossary root map as a "peer" map and associates the key scope name "glossary" with it:
```
  <frontmatter>
  <mapref keyscope="glossary" scope="peer"
    href="aikido-master-glossary-en.ditamap"
    />
  <mapref
    href="intro-to-aikido/topics/graphics/aikido-graphics-keydefs.ditamap"
    />
  <mapref
    href="common/techniques/aikido-technique-resources.ditamap"
  />
  </frontmatter>
```
  It does not otherwise include any key definitions for the glossary entries. The presentation intent is that the the term text will be pulled from the referenced glossary entries but the terms will be made into links only if generation of cross-deliverable links is possible (or is requested if possible). The presumption with a scope of "peer" is that the source files of the peer resource are available at the time the referencing document is processed, so there should be no technical difficulty resolving the key references to get the term text. The processing challenge comes in producing deliverables that make those term references into working cross-deliverable links.
  Out of the box, the Open Toolkit doesn not resolve the cross-publication term references. The OxygenXML editor does resolve cross-publication term references, so you can see what the correct result _should_ be even if the Open Toolkit does not resolve them out of the box. 
  
## Implementing Cross-Publication Term References

Conceptually resolving cross-publication term references simple to get the term text is a simple matter of resolving the peer map reference to the root map and then using that root map as the basis for resolving the key references in the peer map's scope.

That is, given this map reference:
```
  <mapref keyscope="glossary" scope="peer"
    href="aikido-master-glossary-en.ditamap"
    />
```
You resolve the @href value to a map and then construct the key spaces for that map. Having constructed those key spaces you can then resolve key references within them just as you would resolve key references for the initial input map.

So for this key reference made in the content of the map you're publishing:
```
<term keyref="glossary.kokyu"/>
```
You would find the scope "glossary", which in this context is bound to the peer root map `aikido-master-glossary-en.ditamap` and then resolve the key name "kokyu" in that map, which in this example will get you to the glossary entry topic `en/gloss-kokyu.dita` as used in the navigation structure of the master Aikido glossary (as opposed to the same topic used as a resource-only topic within the key scope "gloss-res"). The use context is important because different use contexts might have different effective values for the term text.

If there is no filtering in effect for the content set then the processing is very simple: just use normal XML processing to resolve the references and normal DITA processing to construct the key space and resolve the key name to its resource (topic, text-only key definition, etc.).

However, if there is filtering in effect then things get more complicated because you need to process the target document using the "appropriate" runtime filtering conditions. What "appropriate" is could differ depending on the needs of what you're publishing but typically you would expect "appropriate" to be "the same filtering conditions in effect for the main input map. So if you're publishing the "beginner" version of the Intro to Aikido publication you'd expect to resolve the cross-publication term references from the master glossary filtered on "beginner". But the requirements in practice could be more complicated. For example, maybe the Intro to Aikido publication is filtered but the master glossary is not, with the glossary entries using flagging to distinguish beginner and expert content.

In a case like that you need a per-root-map filtering configuration as part of the processing configuration for the publishing instance you're performing.

This implies that there needs to be some kind of "publishing configuration" mechanism that addresses these requirements as well as other requirements around publication management. As of version 3.3 of the Open Toolkit, the Toolkit team is working on specifying the requirements for some kind of "project configuration" mechanism but hasn't yet started implementing anything.

Note that these are the issues just for _resovling_ cross-publication references. Generating working cross-deliverable links gets even more complicated because in addition to the filtering that might be applied to peer publications you also have to know what deliverable format or formats the links from the deliverable you're producting should be _to_ for each target deliverable. In the simple case you can establish a "like links to like" rule (e.g., PDF links to PDF) but that will not work for many situations, for example, where a PDF needs to link to reference information that is only published as HTML (API reference documentation, for example, where the API is updated constantly and so PDF is neither that useful or that practical).

So the publication-time configuration also has to have some way of configuring knowledge about the target deliverables, including where they will be delivered relative to the deliverable you're generating now. There may also need to be a way to configure the target deliverable on a per-link, per deliverable being linked from basis (although you would hope that that level of complexity can be avoided most of the time).

This implies the need for some kind of "publication manager" that maintains both the publication configuration details and knowledge about what has been published and when. This is the kind of service that would normally be provided by a content management or publication management system and would always need to be tailored or configured to reflect the specific requirements of each publishing organization.

It's a lot.

But in the specific case of simply resolving term text across publications the implementation shouldn't be that difficult.

### Implementing Glossary Generation, Filtering, and Sorting

For glossary processing there are several related use cases:

1. Given a full statically-defined glossary, filter out those terms that are not used directly from non-glossary topics or from directly-used glossary topics, producing the smallest complete glossary that supports the publication.
1. Given a statically-defined set of navigation topicrefs to a glossary (e.g., as direct children of &lt;glossarylist&gt;), sort and group them in a locale-correct way.
1. Given only a set of resource-only topicrefs to glossary entries, generate a set of normal-role topicrefs that reflect either the full set of resource-only glossary entry topics or that reflect the minimum complete set (as for item (1)).

Ideally this processing would be applied to a map for which all the direct-URI maprefs have been resolved and to which branch filtering has been applied but where the final keyref resolution in topics has not been applied.

In terms of both the 3.3 preprocess and preprocess2 Ant targets, that would be between the branch-filter target and the keyref target. There is no extension point there.

However, for both preprocess and preprocess2 the mapref target is implemented using an XSLT transform, `org.dita.base/xsl/preprocess/mapref.xsl` that is extensible. So it would be possible to extend that transform to rework the maps before branch filtering is applied.

This extension point can be used to rework the glossary-related map structures before the map goes to branch filtering or topic-level keyref resolution.

### Cross-Deliverable Implementation with the 3.x Open Toolkit

If I'm understanding the key processing code, the KeyrefModule builds the key spaces, represented by the final root KeyScope object:
```final KeyScope rootScope = reader.getKeyDefinition();```
And then that is passed to the KeyrefPaser [sic] class that processes all the topics that have keyrefs to resolve key references within them using the information in the key spaces.

That suggests that the place to add handling of peer scopes is in KeyrefModule and then KeyrefPaser probably needs to be enhanced to handle the case where a reference is to something in a peer scope.


## DITA OT Notes

* PDF2 transform through 3.2.1 has a bug that causes processing to fail if there are two levels of indirection for a topicref (topicref that uses a keyref to refer a keydef). This bug is fixed in 3.3.






















