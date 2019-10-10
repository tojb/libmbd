# Libmbd

[![build](https://img.shields.io/travis/jhrmnn/libmbd/master.svg)](https://travis-ci.org/jhrmnn/libmbd)
[![coverage](https://img.shields.io/codecov/c/github/jhrmnn/libmbd.svg)](https://codecov.io/gh/jhrmnn/libmbd)
![python](https://img.shields.io/pypi/pyversions/pymbd.svg)
[![release](https://img.shields.io/github/release/jhrmnn/libmbd.svg)](https://github.com/jhrmnn/libmbd/releases)
[![conda](https://img.shields.io/conda/v/libmbd/pymbd.svg)](https://anaconda.org/libmbd/pymbd)
[![pypi](https://img.shields.io/pypi/v/pymbd.svg)](https://pypi.org/project/pymbd/)
[![commits since](https://img.shields.io/github/commits-since/jhrmnn/libmbd/latest.svg)](https://github.com/jhrmnn/libmbd/releases)
[![last commit](https://img.shields.io/github/last-commit/jhrmnn/libmbd.svg)](https://github.com/jhrmnn/libmbd/commits/master)
[![license](https://img.shields.io/github/license/jhrmnn/libmbd.svg)](https://github.com/jhrmnn/libmbd/blob/master/LICENSE)
[![code style](https://img.shields.io/badge/code%20style-black-202020.svg)](https://github.com/ambv/black)

Libmbd contains implementations of the [many-body dispersion](http://dx.doi.org/10.1063/1.4865104) (MBD) method in several programming languages and frameworks:

- The Fortran implementation is the reference, most advanced implementation, with support for analytical gradients and distributed parallelism, and additional functionality beyond the MBD method itself. It provides a low-level and a high-level Fortran API, and a C API. Furthermore, Python bindings to the C API are provided.
- The Python/Numpy implementation is intended for prototyping, and as a high-level language reference.
- The Python/Tensorflow implementation is an experiment that should enable rapid prototyping of machine learning applications with MBD.

The Python-based implementations as well as Python bindings to the Libmbd C API are accessible from the Python package called Pymbd.

## Installing Pymbd

The easiest way to get Pymbd is to install the Pymbd [Conda](https://conda.io/docs/) package, which ships with pre-built Libmbd.

```
conda install -c libmbd pymbd
```

Alternatively, if you have Libmbd installed on your system (see below), you can install Pymbd via Pip, in which case it links against the installed Libmbd. To support Libmbd built with ScaLAPACK/MPI, the `MPI` extras is required.

```
pip install pymbd  # or pymbd[MPI]
```

In both cases, tests can be run with Pytest.

```
pytest -v --durations=3 --pyargs pymbd
```

If you don’t need the Fortran bindings in Pymbd, you can install it without the C extension, in which case `pymbd.fortran` becomes unimportable

```
pip install pymbd --install-option="--no-ext"
```

## Installing Libmbd

Recent releases of conda (2019) may now compile themselves with other compiler versions than the versions on the system that conda is installed on, which means that e.g. the libblas.so in conda might be incompatible with the system libgfortran.so.  No problem! Just install conda's own copies of gfortran, mpi, etc.  Instructions for this are:

```bash
conda install -c conda-forge fortran-compiler
conda install -c conda-forge mpi4py
conda install -c conda-forge openmpi-mpifort
```

Providing you can make sure that conda's mpifort (~/anaconda3/bin/mpifort) and not the system mpifort are on-path you can then build with cmake following the instructions below:


```
git clone https://github.com/jhrmnn/libmbd.git && cd libmbd
mkdir build && cd build
cmake .. [-DENABLE_SCALAPACK_MPI=ON]
make
```
Having done this you obviously cannot install the libmbd to your system path however you can install it to your conda path, which is what you wanted if you are reading the conda version of the installation instructions.

```
make install
```

This installs the Libmbd shared library, C API header file, and high-level Fortran API module file.

Tests can be run with

```
make check
```

## Examples

```python
from pymbd import mbd_energy_species, ang
from pymbd.fortran import MBDCalc

ene_py = mbd_energy_species(  # pure Python implementation
    [(0, 0, 0), (0, 0, 4*ang)], ['Ar', 'Ar'], [1, 1], 0.83
)
with MBDCalc() as calc:
    ene_f = calc.mbd_energy_species(  # Fortran implementation
        [(0, 0, 0), (0, 0, 4*ang)], ['Ar', 'Ar'], [1, 1], 0.83
    )
assert abs(ene_f-ene_py) < 1e-15
```

```fortran
use mbd, only: mbd_input_t, mbd_calc_t

type(mbd_input_t) :: inp
type(mbd_calc_t) :: calc
real(8) :: energy, gradients(3, 2)
integer :: code
character(200) :: origin, msg

inp%atom_types = ['Ar', 'Ar']
inp%coords = reshape([0d0, 0d0, 0d0, 0d0, 0d0, 7.5d0], [3, 2])
inp%xc = 'pbe'
call calc%init(inp)
call calc%get_exception(code, origin, msg)
if (code > 0) then
    print *, msg
    stop
end if
call calc%update_vdw_params_from_ratios([0.98d0, 0.98d0])
call calc%evaluate_vdw_method(energy)
call calc%get_gradients(gradients)
call calc%destroy()
```

## Links

- Libmbd documentation: https://jhrmnn.github.io/libmbd
- Pymbd documentation: https://jhrmnn.github.io/libmbd/pymbd

## Developing

For development, Libmbd doesn't have to be installed on the system, and Pymbd can be linked against Libmbd in the build directory. Use [Tox](https://tox.readthedocs.io/) for comfortable running of Python tests.

```
pip install tox tox-venv  # or just make sure you have tox and tox-venv installed
git clone https://github.com/jhrmnn/libmbd.git && cd libmbd
make setup  # creates ./build and runs cmake
# do some development
make test && tox
# do some development
make test && tox
```
