// ignore_for_file: cascade_invocations, prefer_final_locals

import 'package:state_beacon_core/src/creator/creator.dart';
import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

void main() {
  /*
    a  b          a 
    | /     or    | 
    c             c
  */
  test('dynamic sources recalculate correctly', () {
    var a = Beacon.writable(false);
    var b = Beacon.writable(2);
    var count = 0;

    var c = Beacon.derived(() {
      count++;
      return a.value ? a.value : b.value;
    });

    expect(c.value, 2);
    expect(count, 1);

    a.value = true;

    expect(c.value, true);
    expect(count, 2);

    b.value = 4;
    expect(c.value, true);
    expect(count, 2);
  });

  /*
  dependency is dynamic: sometimes l depends on b, sometimes not.
     s          s
    / \        / \
   a   b  or  a   b
    \ /        \
     l          l
  */
  test("dynamic sources don't re-execute a parent unnecessarily", () {
    var s = Beacon.writable(2);
    var a = Beacon.derived(() => s.value + 1);
    var bcount = 0;

    var b = Beacon.derived(() {
      bcount++;
      return s.value + 10;
    });

    var l = Beacon.derived(() {
      var result = a.value;
      // Check if 'result' is odd
      if (result & 0x1 != 0) {
        result += b.value;
      }
      return result;
    });

    expect(l.value, 15);
    expect(bcount, 1);

    s.value = 3;
    expect(bcount, 1);
    s.value = 3;
    expect(l.value, 4);
    expect(bcount, 1);
  });

  /*
    s
    |
    l
  */
  test('dynamic source disappears entirely"', () {
    var s = Beacon.writable(1);
    var done = false;
    var count = 0;

    var c = Beacon.derived(() {
      count++;

      if (done) {
        return 0;
      } else {
        var value = s.value;
        if (value > 2) {
          done = true; // break the link between s and c
        }
        return value;
      }
    });

    expect(c.value, 1);
    expect(count, 1);
    s.value = 3;
    expect(c.value, 3);
    expect(count, 2);

    s.value = 1; // we've now locked into 'done' state
    expect(c.value, 0);
    expect(count, 3);

    // we're still locked into 'done' state, and count no longer advances
    // in fact, c() will never execute again..
    s.value = 0;
    expect(c.value, 0);
    expect(count, 3);
  });

  test('small dynamic graph with Beacon.writable grandparents', () {
    var z = Beacon.writable(3);
    var x = Beacon.writable(0);

    var y = Beacon.writable(0);
    var i = Beacon.derived(() {
      var a = y.value;
      z.value;
      if (a == 0) {
        return x.value;
      } else {
        return a;
      }
    });
    var j = Beacon.derived(() {
      var a = i.value;
      z.value;
      if (a == 0) {
        return x.value;
      } else {
        return a;
      }
    });
    j.value;
    x.value = 1;
    j.value;
    y.value = 1;
    j.value;
  });
}
