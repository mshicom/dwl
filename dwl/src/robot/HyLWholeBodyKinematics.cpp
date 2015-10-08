#include <robot/HyLWholeBodyKinematics.h>


namespace dwl
{

namespace robot
{

HyLWholeBodyKinematics::HyLWholeBodyKinematics()
{
	// Defining the end-effector ids
	body_id_["foot"] = 0;

	// Defining the jacobians of the end-effectors
	jacobians_["foot"] = jacs_.fr_trunk_J_fr_foot;

	// Defining the homogeneous transforms of the end-effectors
	homogeneous_tf_["foot"] = hom_tf_.fr_trunk_X_fr_foot;

	// Computing the number of joints given the jacobians
	for (rbd::BodyID::iterator body_iter = body_id_.begin();
			body_iter != body_id_.end();
			body_iter++)
	{
		std::string effector_name = body_iter->first;
		Eigen::MatrixXd jac = jacobians_.find(effector_name)->second;
		num_joints_ += jac.cols();
	}

	floating_base_rot_ = Eigen::Matrix3d::Identity();
}


HyLWholeBodyKinematics::~HyLWholeBodyKinematics()
{

}


void HyLWholeBodyKinematics::updateState(const rbd::Vector6d& base_pos,
										 	  const Eigen::VectorXd& joint_pos)
{
//	if (joint_pos.size() > 2)
//		printf("Error the joint position must be 2");

	// Computing the HyL state
	Eigen::Vector3d state;
	state << base_pos(rbd::LZ), joint_pos;

	// Updating jacobians
	jacobians_["foot"] = jacs_.fr_trunk_J_fr_foot(state);

	// Updating homogeneous transforms
	homogeneous_tf_["foot"] = hom_tf_.fr_trunk_X_fr_foot(state);
}


void HyLWholeBodyKinematics::computeInverseKinematics(Eigen::VectorXd& joint_pos,
													  Eigen::VectorXd& joint_vel,
													  const Eigen::VectorXd& op_pos,
													  const Eigen::VectorXd& op_vel)
{

	Eigen::Vector3d hipassembly2hfe = rbd::translationVector(hom_tf_.fr_trunk_X_fr_upperleg);

	double upperleg_length =
			(rbd::translationVector(hom_tf_.fr_upperleg_X_fr_lowerleg)).norm();
	double lowerleg_length =
			(rbd::translationVector(hom_tf_.fr_lowerleg_X_fr_foot)).norm();

	Eigen::Vector3d hipassembly2foot = op_pos - hipassembly2hfe;
	double hfe2foot_dist = sqrt((double) (hipassembly2foot(rbd::X) * hipassembly2foot(rbd::X)) +
			(double) (hipassembly2foot(rbd::Z) * hipassembly2foot(rbd::Z)));

	// Joint positions
	joint_pos(iit::HyL::HFE-1) = -asin((double) hipassembly2foot(rbd::X) / hfe2foot_dist) +
			acos((upperleg_length * upperleg_length + hfe2foot_dist * hfe2foot_dist -
			lowerleg_length * lowerleg_length) / (2 * upperleg_length * hfe2foot_dist));

	joint_pos(iit::HyL::KFE-1) = acos((upperleg_length * upperleg_length +
			lowerleg_length * lowerleg_length - hfe2foot_dist * hfe2foot_dist) /
			(2 * upperleg_length * lowerleg_length)) - M_PI;

	// Joint velocities
	Eigen::MatrixXd jacobian;
	rbd::BodySelector body_set;
	body_set.push_back("foot");
	computeFixedBaseJacobian(jacobian, joint_pos, body_set, rbd::Linear);

	Eigen::MatrixXd pinv_jac = math::pseudoInverse(jacobian);
	joint_vel = pinv_jac * op_vel;
}

} //@namespace robot
} //@namespace dwl