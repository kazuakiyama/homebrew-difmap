# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Difmap < Formula
  desc "DIFMAP: A Caltech VLBI Program"
  version "2.5e"
  homepage "http://www.astro.caltech.edu/~tjp/citvlb/index.html"
  url "ftp://ftp.astro.caltech.edu/pub/difmap/difmap2.5e.tar.gz"
  sha256 "457cd77c146e22b5332403c19b29485388a863ec494fff87137176396fc6a9ff"

  depends_on "gcc"
  depends_on "pgplot"
  depends_on :x11

  fails_with :clang do
    cause "Miscompilation resulting in segfault on queries"
  end

  fails_with :llvm do
    cause "Miscompilation resulting in segfault on queries"
  end

  patch :DATA

  def install
    ENV.fortran
    ENV.deparallelize
    ENV.append "CCOMPL", :gcc
    
    pgplotlib =  "-L#{HOMEBREW_PREFIX}/lib -lpgplot -lX11 -lpng"

    inreplace 'configure' do |s|
      s.change_make_var! "HELPDIR", prefix
      s.change_make_var! "PGPLOT_LIB", pgplotlib
    end

    system "./configure intel-osx-gcc"
    system "./makeall"
    
    prefix.install Dir['help/*.hlp']
    bin.install ['difmap']
  end

  def caveats
    msg = <<~EOF
Don't forget to add paths for PGPLOT before using DIFMAP.
For instance, you can add the following lines to your ~/.bash_profile or ~/.zshrc file
(and remember to source the file to update your current session):

PGPLOT_DIR=`brew --prefix pgplot`/share
if [ -e $PGPLOT_DIR ]; then
  export PGPLOT_DIR=$PGPLOT_DIR
  export PGPLOT_DEV=/xwin       # This is up to your preference. /xserve might be your choise.
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PGPLOT_DIR
fi
EOF
  end
end
__END__
diff --git a/configure b/configure
index 0e48dfb..51a1e4d 100755
--- a/configure
+++ b/configure
@@ -326,7 +326,7 @@ case $OS in
 ;;
 
   apple-osx-gcc)   # Macintosh computer running OSX, using the Gnu C compiler.
-    CC=gcc-4
+    CC=$CCOMPL
     FC=gfortran
     CFLAGS="$CFLAGS -Dapple_osx"
 #
@@ -347,7 +347,7 @@ case $OS in
 ;;
 
   intel-osx-gcc)   # Macintosh computer running OSX, using the Gnu C compiler.
-    CC=gcc-4
+    CC=$CCOMPL
     FC=gfortran
     CFLAGS="$CFLAGS -Dintel_osx"
 #
