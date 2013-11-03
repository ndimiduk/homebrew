require 'formula'

class Openjdk7 < Formula
  homepage 'http://openjdk.java.net/'
  url 'http://www.java.net/download/openjdk/jdk7u40/promoted/b43/openjdk-7u40-fcs-src-b43-26_aug_2013.zip'
  sha1 'f3070ee95d40b1fc9fc6d7d79c7c246f184c7a3e'
  version 'jdk7u40'

  depends_on 'freetype' => :build

  option 'with-javadoc', 'enable building javadoc'

  def install
    args = ['JAVA_HOME=', 'LD_LIBRARY_PATH=']
    args << 'LC_ALL=C'
    args << 'LANG=C'
    args << "ALT_BOOTDIR=$(/usr/libexec/java_home -v 1.6)"
    # to get CORBA to build, this is probably a hack
    # see http://grokbase.com/t/openjdk/build-dev/0835d3c1jz/jdk-import-path
    args << "ALT_JDK_IMPORT_PATH=$(/usr/libexec/java_home -v 1.6)"
    args << "ALT_FREETYPE_HEADERS_PATH=#{prefix}/include"
    args << "ALT_FREETYPE_LIB_PATH=#{prefix}/lib"
    args << 'ANT_HOME=/usr/share/ant'
    args << 'SA_APPLE_BOOT_JAVA=true'
    args << 'ALWAYS_PASS_TEST_GAMMA=true'
    args << 'NO_DOCS=true' unless build.include? 'with-javadoc'

    # TODO: corba src jar fails; hotspot fails
    system "make", *args

    # TODO: install image
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! It's enough to just replace
    # "false" with the main program this formula installs, but it'd be nice if you
    # were more thorough. Run the test with `brew test openjdk-7u40-fcs-src-b43-26_aug`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "--version"`.
    system "false"
    # TODO: anything here?
  end
end
