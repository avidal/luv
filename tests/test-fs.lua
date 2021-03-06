return require('lib/tap')(function (test)

  test("read a file sync", function (print, p, expect, uv)
    local fd = assert(uv.fs_open('README.md', 'r', tonumber('644', 8)))
    p{fd=fd}
    local stat = assert(uv.fs_fstat(fd))
    p{stat=stat}
    local chunk = assert(uv.fs_read(fd, stat.size, 0))
    assert(#chunk == stat.size)
    assert(uv.fs_close(fd))
  end)

  test("read a file async", function (print, p, expect, uv)
    uv.fs_open('README.md', 'r', tonumber('644', 8), expect(function (err, fd)
      assert(not err, err)
      p{fd=fd}
      uv.fs_fstat(fd, expect(function (err, stat)
        assert(not err, err)
        p{stat=stat}
        uv.fs_read(fd, stat.size, 0, expect(function (err, chunk)
          assert(not err, err)
          p{chunk=#chunk}
          assert(#chunk == stat.size)
          uv.fs_close(fd, expect(function (err)
            assert(not err, err)
          end))
        end))
      end))
    end))
  end)

  test("fs.stat sync", function (print, p, expect, uv)
    local stat = assert(uv.fs_stat("README.md"))
    assert(stat.size)
  end)

  test("fs.stat async", function (print, p, expect, uv)
    assert(uv.fs_stat("README.md", expect(function (err, stat)
      assert(not err, err)
      assert(stat.size)
    end)))
  end)

  test("fs.stat sync error", function (print, p, expect, uv)
    local stat, err, code = uv.fs_stat("BAD_FILE!")
    p{err=err,code=code,stat=stat}
    assert(not stat)
    assert(err)
    assert(code == "ENOENT")
  end)

  test("fs.stat async error", function (print, p, expect, uv)
    assert(uv.fs_stat("BAD_FILE@", expect(function (err, stat)
      p{err=err,stat=stat}
      assert(err)
      assert(not stat)
    end)))
  end)


end)
