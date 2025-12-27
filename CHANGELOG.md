- [Version 0.3.0 <span class="timestamp-wrapper"><span class="timestamp">[2025-12-27 Sat]</span></span>](#org9bad058)
- [Version 0.2.0 <span class="timestamp-wrapper"><span class="timestamp">[2025-12-23 Tue]</span></span>](#org58322aa)
- [Version 0.1.2 <span class="timestamp-wrapper"><span class="timestamp">[2025-12-23 Tue]</span></span>](#org4807738)


<a id="org9bad058"></a>

# Version 0.3.0 <span class="timestamp-wrapper"><span class="timestamp">[2025-12-27 Sat]</span></span>

-   Added export of CHANGELOG.org to CHANGELOG.md
-   Added this CHANGELOG so I have an example to use in my specs. Oh, and for users also.


<a id="org58322aa"></a>

# Version 0.2.0 <span class="timestamp-wrapper"><span class="timestamp">[2025-12-23 Tue]</span></span>

-   Make tangle of README.org unconditional, even is it is not newer than README.md. The code examples depend on more than just the text of README.org, they especially depend on changes to the gem's lib code, so running unconditionally is usually what is wanted.
-   Before docs:tangle, kill the session buffer for ruby code blocks so each run is independent of prior runs and the current version of the gem lib gets loaded.


<a id="org4807738"></a>

# Version 0.1.2 <span class="timestamp-wrapper"><span class="timestamp">[2025-12-23 Tue]</span></span>

-   Initial release
