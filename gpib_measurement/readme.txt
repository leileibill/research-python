Pilawa Instruments
==================
Package format adopted on August 8, 2013.
Last revised on: 8/13/2013


"pilawa_instruments.py" must be kept in the same directory as "pilawa_package" to work correctly.

"pilawa_instruments.py" imports all modules and classes from the package in a concise naming scheme.
Use 'from pilawa_instruments import <class_name>' or 'from pilawa_instruments import *' (unchanged from our traditional syntax).

If adding new files, please remember to update both "__init__.py" of the directory and "pilawa_instruments.py". When making any changes, updating the revision dates of the files changed, "pilawa_instruments.py", and this readme would be helpful.


Important Changes (that may break some old code)
=================
-"xhr4025" renamed to "prologix_xhr4025" for consistency (class was not originally part of "pilawa_instruments.py", so this is just a heads-up for people switching to the new package format)