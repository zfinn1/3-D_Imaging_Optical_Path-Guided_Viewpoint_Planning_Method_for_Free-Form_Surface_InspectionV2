# 3-D_Imaging_Optical_Path-Guided_Viewpoint_Planning_Method_for_Free-Form_Surface_Inspection

- `G(Ψ)`: Total number of viewpoints required.
- `C(Ψ)`: Coverage overlap penalty.
- `K(Ψ)`: Local curvature variance (smoothness prior).

## 🗺️ System Framework

![Framework](assets/framework.png)
*Workflow: 3D model → Initial viewpoint → Radial flipping → Axial expansion → Adaptive correction → Global optimization → Path planning.*

## 📊 Experimental Results

### Simulation on Aero-engine Blades
- **Models**: Turbine blade (3337 patches) & Turbofan blade (3789 patches).
- **Metrics**: Uncovered rate (η_u) and minimum number of viewpoints (n*).

| Model | Method | η_u=0.05 | η_u=0.01 | Avg. Reduction |
|-------|--------|----------|----------|----------------|
| Model 1 | VP-Sampling | 57 | 84 | - |
| | VP-VDMO | 57 | 86 | - |
| | **Ours** | **31** | **43** | **45.6%** |
| Model 2 | VP-Sampling | 100 | 100 | - |
| | VP-Clustering | 86 | 100 | - |
| | **Ours** | **68** | **81** | **23.1%** |

### Real-world Deployment
- **Robot**: UR5e with industrial camera (12×12mm FOV, Δd=2mm).
- **Result**: Achieved η_u=0.05 with only **24 viewpoints**, completing collision-free inspection paths.

![RealWorld](assets/realworld.png)

## 🚀 Getting Started

### Prerequisites
- Python 3.8+
- PyTorch (optional, only for visualization)
- NumPy, SciPy, Trimesh, Open3D, Meshplot

### Installation
```bash
git clone https://github.com/yourusername/IOP-VP.git
cd IOP-VP
pip install -r requirements.txt
