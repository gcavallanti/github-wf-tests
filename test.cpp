#include <boost/numeric/ublas/vector_sparse.hpp>
#include <boost/numeric/ublas/io.hpp>
#include <boost/numeric/ublas/vector.hpp>
#include <boost/numeric/ublas/vector_proxy.hpp>
#include <boost/numeric/ublas/matrix.hpp>
#include <boost/numeric/ublas/triangular.hpp>
#include <boost/numeric/ublas/lu.hpp>
#include "algorithms/dualmultitaskkernelperceptron.h"
#include "protocols/classification.h"
#include "data/builderbinaryvectortasknumber.h"
#include "generators/datasetbinaryvectortasknumber.h"
#include "utilities/commandline/parserkernelarg.h"
#include "utilities/kernelwrapper.h"


template<class T>
bool invertMatrix (const boost::numeric::ublas::matrix<T>& input, boost::numeric::ublas::matrix<T>& inverse) {
  using namespace boost::numeric::ublas;
  typedef permutation_matrix<std::size_t> pmatrix;
  // create a working copy of the input
  matrix<T> A(input);
  // create a permutation matrix for the LU-factorization
  pmatrix pm(A.size1());

  // perform LU-factorization
  int res = lu_factorize(A,pm);
  if( res != 0 ) return false;

  // create identity matrix of "inverse"
  inverse.assign(boost::numeric::ublas::identity_matrix<T>(A.size1()));

  // backsubstitute to get the inverse
  lu_substitute(A, pm, inverse);

  return true;
};



int main(int argc, char *argv[])
{
  using namespace lol;

  std::string kArg = argv[1];
  std::string bArg = argv[2];
  std::string runsCountArg = argv[3];
  std::string kernelArg = argv[4];
  std::string trainingLogArg = argv[5];
  std::string datasetArg = argv[6];


  unsigned k = atoi(kArg.c_str());
  double b = atof(bArg.c_str());
  unsigned runsCount = atoi(runsCountArg.c_str());
  KernelWrapper kernel(parseKernelArg(kernelArg));


  double a = k + b*(k - 1);

  boost::numeric::ublas::matrix<double> interactionMatrix(k, k);
  for (unsigned i = 0; i < interactionMatrix.size1 (); ++ i)
    for (unsigned j = 0; j < interactionMatrix.size2 (); ++ j)
      if (i == j)
        interactionMatrix(i, j) = a / k;
      else
        interactionMatrix(i, j) = -b / k;

  boost::numeric::ublas::matrix<double> inverseInteractionMatrix(k, k);
  invertMatrix<double>(interactionMatrix, inverseInteractionMatrix);


  DualMultitaskkernelPerceptron< boost::numeric::ublas::matrix<double>, 
    KernelWrapper, InstanceVectorTasknumber > dualMultitaskkernelPerceptron(inverseInteractionMatrix, kernel, k);

  BuilderBinaryVectorTasknumber builderBinaryVectorTasknumber;

  DatasetBinaryVectorTasknumber< BuilderBinaryVectorTasknumber > 
    dataset(datasetArg, builderBinaryVectorTasknumber);

  Classification< DatasetBinaryVectorTasknumber< BuilderBinaryVectorTasknumber > , 
    double > classification;
  
  std::ofstream trainingLog(trainingLogArg.c_str());

  classification.train(dataset, trainingLog, 
		       dualMultitaskkernelPerceptron, runsCount); 
}


