ic
==

This is a generalized ETL framework for pulling data from a remote source, transforming it, 
and storing it in a database.

Currently, it just pulls employment data from the US Bureau of Labor Statistics, but it can be
adapted to work with any data sets. One of the principles of this project is to allow you to
specify much of your ETL process through simple configuration, and then allow custom transformations
with Ruby.

This project provides the data behind the clarity web-based query ui. Clarity at https://github.com/diamondap/clarity

Copyright (C) 2012-2013 A. Diamond

Distributed under the Eclipse Public License.
