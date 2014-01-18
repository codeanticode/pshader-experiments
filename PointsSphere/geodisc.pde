public class Geodesic {

  private int N; //Tesselation frequency

  private int vertNum; // Number of vertices
  private int next;
  private boolean closecheck;
  /** Creates a new instance of Geodesic */

  public Geodesic(int tesselationFrequency)

  {
    //  N = tesselationFrequency;
    int vertcount = 0;
    next = 0;
    closecheck = false;
    while (vertNum < tesselationFrequency) {
      N = round(sqrt((tesselationFrequency-2)/10)) + vertcount;

      vertNum = 10*N*N+2;
      vertcount = vertcount + 1;
    }
    // println(N);
    //println(vertNum);
  }

  public int getNextNode() {
    return next;
  }

  public Point3d[] getPointList()

  {

    Point3d[] pointList = new Point3d[vertNum];



    for (int i = 0; i < vertNum; i++)

    {

      pointList[i] = createGeo(i);
      if (!closecheck) {
        if (next == 0) {
          next = i;
        } 
        else {
          Vector3d ps1 = new Vector3d(pointList[0]);
          Vector3d ps2 = new Vector3d(pointList[next]);
          Vector3d ps3 = new Vector3d(pointList[i]);
          float pdist1 = dist((float)ps1.x, (float)ps1.y, (float)ps1.z, (float)ps2.x, (float)ps2.y, (float)ps2.z);
          float pdist2 = dist((float)ps1.x, (float)ps1.y, (float)ps1.z, (float)ps3.x, (float)ps3.y, (float)ps3.z);
          if (pdist2 < pdist1) {
            next = i;
          }
        }
      }
    }
    closecheck = true;
    return pointList;
  }



  public int getNumberOfPoints()

  {

    return vertNum;
  }







  // x mod y

  private double mod(double x, double y)

  {

    return (y == 0) ? x : (x - (double)Math.floor(x/y)*y);
  }



  /* createGeo(m,N) outputs spherical coordinates of a geodesic sphere.
   
   * Where m is a single integer between 0 and 10N^2 + 2
   
   *        and values of m correspond to:
   
   *
   
   *                             0<= m < 12         Icosahedron vertex point
   
   *                           12 <= m < 30N - 18   Icosahedron edge point
   
   *                     30N - 18 <= m < 10N^2 + 2  Interior surface point
   
   */



  private Point3d createGeo(int m)

  {         

    SphericalCoordinates sc;



    if (m == 0)

    {

      sc = getPoint(0, 0, 1); //Top Vertex
    }

    else if (m == 1)

    {

      sc = getPoint(0, 0, 20); //Bottom Vertex;
    }

    else if (m < 12)

    {

      sc = getPoint(0, 0, m+4); //Top of one of the middle vertices
    }

    else if (m < 30*N -18) //Icosahedron edges

    {

      int edge  = (int)mod(m-12, 30); 

      int point = (int)Math.floor((m-12)/30);



      if (edge < 5)

      {

        sc = getPoint(0, point + 1, edge + 1);
      }

      else if (edge < 10)

      {

        sc = getPoint(point + 1, N-(point + 1), edge - 4);
      }

      else if (edge < 15)

      {

        sc = getPoint(0, point+1, edge - 4);
      }

      else if (edge < 20)

      {

        sc = getPoint(point + 1, 0, edge - 9);
      }

      else if (edge < 25)

      {

        sc = getPoint(point + 1, N-(point + 1), edge - 4);
      }

      else

      {

        sc = getPoint(0, point + 1, edge - 9);
      }
    }

    else    //Inner vertices

    {

      int face = (int)mod((m-(30*N)+18), 20);

      int point = (int)Math.floor((m-(30*N)+18)/20)+1;

      int offset = N - 2;

      int z;

      for (z = 1; z <=N; z++)

      {

        if (point <= offset)

        {

          break;
        }

        else

        {

          offset = offset + N - (z + 2);
        }
      }



      int y = offset - point + 1;

      int x = N - y - z;

      sc = getPoint(x, y, face + 1);
    }        

    return sc.getCartesian();
  }





  public SphericalCoordinates getPoint(int x, int y, int face)

  {

    SphericalCoordinates sc = topFace(x, y);



    if (face == 1)

    {
    }

    else if (face <= 5)

    {

      rotate(sc, face-1);
    }

    else if (face <= 10)

    {

      shiftDown(sc, face - 5);
    }

    else if (face <= 15)

    {

      shiftDown(sc, face - 10);

      flip(sc);
    }

    else

    {

      rotate(sc, face - 16);

      flip(sc);
    }         

    return sc;
  }          



  private SphericalCoordinates topFace(int x, int y)

  {

    int z = N - x - y;

    double x1 = x*Math.sin(2*Math.PI/5);

    double y1 = y + x*Math.cos(2*Math.PI/5);

    double z1 = .5*N + (N - x - y)/((1 + Math.sqrt(5))/2);

    double phi = Math.atan2(x1, y1);

    double theta = Math.atan2(Math.sqrt(Math.pow(x1, 2) + Math.pow(y1, 2)), z1);

    SphericalCoordinates sc = new SphericalCoordinates(theta, phi);

    return sc;
  }



  private void rotate(SphericalCoordinates sc, int number)

  {

    sc.phi = sc.phi + number*2*Math.PI/5;
  }



  private void shiftDown(SphericalCoordinates sc, int number)

  {

    rotate(sc, number - 1);

    double phi0 = Math.PI/5 + 2*(number - 1)*Math.PI/5;

    Point3d p3d = new Point3d();

    double r1 = Math.sin(sc.theta)*Math.cos(sc.phi - phi0);

    double r3 = Math.cos(sc.theta);

    double sqrt5 = Math.sqrt(5);



    p3d.x = r1/sqrt5 + 2*r3/sqrt5;

    p3d.y = Math.sin(sc.theta)*Math.sin(sc.phi - phi0);

    p3d.z = r3/sqrt5 - 2*r1/sqrt5;



    sc.phi = phi0 + Math.PI/5 + Math.atan2(p3d.y, p3d.x);

    sc.theta = Math.atan2(Math.sqrt(p3d.x*p3d.x + p3d.y*p3d.y), p3d.z);
  } 



  private void flip(SphericalCoordinates sc)

  {

    sc.phi = sc.phi + Math.PI/5;

    sc.theta = Math.PI - sc.theta;
  }
}

public class SphericalCoordinates {
  double r;
  double theta;
  double phi;


  public SphericalCoordinates(int x, int y)
  {
    r = radius;
    theta = (double) x;
    phi = (double) y;
  }

  public SphericalCoordinates(double x, double y)
  {
    r = radius;
    theta = x;
    phi = y;
  }




  Point3d getCartesian() {
    final double xyz[] = new double[3];
    xyz[0] = r * Math.sin(theta) * Math.cos(phi);
    xyz[1] = r * Math.sin(theta) * Math.sin(phi);
    xyz[2] = r * Math.cos(theta);
    Point3d ps = new Point3d(xyz);
    return ps ;
  }
}

int fastDist( int dx, int dy )
{
  int min, max, approx;

  if ( dx < 0 ) dx = -dx;
  if ( dy < 0 ) dy = -dy;

  if ( dx < dy )
  {
    min = dx;
    max = dy;
  } 
  else {
    min = dy;
    max = dx;
  }

  approx = ( max * 1007 ) + ( min * 441 );
  if ( max < ( min << 4 ))
    approx -= ( max * 40 );

  // add 512 for proper rounding
  return (( approx + 512 ) >> 10 );
} 
