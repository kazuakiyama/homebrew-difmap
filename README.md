# homebrew-difmap
This is a Homebrew formula for DIFMAP, one of [Caltech's VLBI software packages](http://www.astro.caltech.edu/~tjp/citvlb/index.html). 
This allows a quick install of DIFMAP for macOS+homebrew users.

## Installation of DIFMAP with brew using this formula
homebrew recently removed pgplot for a Licence issue. 
I made [a back up (+ minor modificaiton) of the latest pgplot formula just before being removed](https://github.com/kazuakiyama/homebrew-pgplot).
You just need to tap this repository and install difmap.

```bash
# install PGPLOT
brew tap kazuakiyama/pgplot
brew install pgplot

# install DIFMAP
brew tap kazuakiyama/difmap
brew install difmap
```

Don't forget to add paths for PGPLOT before using DIFMAP.
For instance, you can add the following line to your ~/.bashrc_profile or ~/.zprofile files (and remember to source the file to update your current session):

```bash
PGPLOT_DIR=`brew --prefix pgplot`/lib
if [ -e $PGPLOT_DIR ]; then
  export PGPLOT_DIR=$PGPLOT_DIR
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PGPLOT_DIR
  export PGPLOT_DEV=/xwin # This is up to your preference. /xserve might be your choise.
fi
```

Help files and other material will be copied to a Cellar directory for DIFMAP. You can get the directory path by

```bash
brew --prefix difmap
```


## Contact
If you find any issues related to this brew formula, please post [issues](https://github.com/kazuakiyama/homebrew-difmap/issues) in this github repository
or directly contact me ([Kazu Akiyama](https://sites.mit.edu/kazuakiyama)). I would note that, as I'm **no longer an active user of DIFMAP**, 
I do not frequently check the latest version of the package. Please contact me if you find a newer version of DIFMAP which is not yet reflected in my formula.
For any issues on DIFMAP itself, you should contact Martin C. Shepherd at Caltech maintaining [DIFMAP](http://www.astro.caltech.edu/~tjp/citvlb/index.html).
