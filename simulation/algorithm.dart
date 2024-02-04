import 'dart:math';

class Traject{
  List<double> start;
  List<double> end;
  List<int> time;
  int userId;

  Traject(List<double> this.start, List<double> this.end, List<int> this.time, int this.userId);
}

List<List<double>> trajects = [];

double dot(List<double> u,List<double> v){
  return u[0]*v[0] + u[1]*v[1];
}

double norm(List<double> u){
  return sqrt(dot(u,u));
}

List<double> scal(double k,List<double> u){
  List<double> out = [k*u[0],k*u[1]];
  return out;
}

List<double> add(List<double> u,List<double> v){
  List<double> out = [u[0]+v[0],u[1]+v[1]];
  return out;
}

List<double> sub(List<double> u,List<double> v){
  return add(u,scal(-1.0,v));
}

double distL(List<double> u,List<double> v,List<double> w){
  List<double> x = sub(v,u);
  List<double> y = sub(w,u);

  List<double> proj = add(u,scal(dot(x,y)/dot(x,x),x));
  return norm(sub(w,proj));
}

Traject eille = Traject([1.0,2.0],[3.0,4.0],[1,2,3],293874);

List<int> point= [4023,-12639];

Map<List<int>,Traject> localtrajects = {
  point: eille,
};

void main() {
  List<double> u = [4,5];
  List<double> v = [10,8];
  List<double> w = [6];
  w.add(5);
  print(distL(u,v,w));

  Traject eille = Traject([1.0,2.0],[3.0,4.0],[1,2,3],293874);
  print(localtrajects[point]?.start);
}