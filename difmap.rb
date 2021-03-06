class Difmap < Formula
  desc "DIFMAP: A Caltech VLBI Program"
  homepage "http://www.astro.caltech.edu/~tjp/citvlb/index.html"
  url "ftp://ftp.astro.caltech.edu/pub/difmap/difmap2.5k.tar.gz"
  sha256 "d754dcc094a758a817677fe493bde13408cc270910f6bb7bbc3487e002cc184e"
  version "2.5k"
  
  depends_on "gcc"
  depends_on "libx11"
  depends_on "pgplot"

  fails_with :clang do
    cause "Miscompilation resulting in segfault on queries"
  end

  patch :DATA

  def install
    ENV.fortran
    ENV.deparallelize
    ENV.append "CCOMPL", :gcc

    pgplotlib = "-L#{HOMEBREW_PREFIX}/lib -lpgplot -lX11 -lpng"

    inreplace "configure" do |s|
      s.change_make_var! "HELPDIR", prefix
      s.change_make_var! "PGPLOT_LIB", pgplotlib
    end

    system "./configure", "intel-osx-gcc"
    system "./makeall"

    prefix.install Dir["help/*.hlp"]
    bin.install ["difmap"]
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
    msg
  end

  test do
    system "false"
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
