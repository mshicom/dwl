#ifndef DWL__MODEL__FLOATING_BASE_SYSTEM__H
#define DWL__MODEL__FLOATING_BASE_SYSTEM__H

#include <rbdl/rbdl.h>
#include <rbdl/addons/urdfreader/urdfreader.h>
#include <dwl/utils/RigidBodyDynamics.h>
#include <dwl/utils/URDF.h>
#include <dwl/utils/Math.h>
#include <fstream>


namespace dwl
{

namespace model
{

enum TypeOfSystem {FixedBase, FloatingBase, ConstrainedFloatingBase, VirtualFloatingBase};

/** @brief Defines a floating-base joint information */
struct FloatingBaseJoint {
	FloatingBaseJoint(bool status) : active(status), constrained(false), id(0) {}
	FloatingBaseJoint(bool status,
					  unsigned int _id,
					  std::string _name) : active(status), constrained(false), id(_id), name(_name) {}
	bool active;
	bool constrained;
	unsigned int id;
	std::string name;
};

/** @brief Defines an actuated joint information */
struct Joint {
	Joint(unsigned int _id,
		  std::string _name) : id(_id), name(_name) {}
	unsigned int id;
	std::string name;
};

/**
 * @class FloatingBaseSystem
 * @brief FloatingBaseSystem class read the floating-base system information from an URDF file.
 * Additionally, it has methods that allows us easily to manipulate joint states which depends on
 * the floating-base system kinematic-tree
 */
class FloatingBaseSystem
{
	public:
		/** @brief Constructor function */
		FloatingBaseSystem(bool full = false, unsigned int _num_joints = 0);

		/** @brief Destructor function */
		~FloatingBaseSystem();

		/**
		 * @brief Resets the system information from an URDF file
		 * @param std::string URDF filename
		 */
		void resetFromURDFFile(std::string filename);

		/**
		 * @brief Resets the system information from URDF model
		 * @param std::string URDF model
		 */
		void resetFromURDFModel(std::string urdf_model);

		/**
		 * @brief Sets the 6d floating-base joint information
		 * @param const FloatingBaseJoint& Floating-base joint information
		 **/
		void setFloatingBaseJoint(const FloatingBaseJoint& joint);

		/**
		 * @brief Sets the floating-base joint information
		 * @param const FloatingBaseJoint& Floating-base joint information
		 * @param rbd::Coords6d Joint coordinate
		 **/
		void setFloatingBaseJoint(const FloatingBaseJoint& joint,
								  rbd::Coords6d joint_coord);

		/**
		 * @brief Sets the actuated joint information
		 * @param const Joint& Joint information
		 */
		void setJoint(const Joint& joint);

		/**
		 * @brief Sets the floating-base constraint information
		 * @param rbd::Coords6d Joint coordinate
		 */
		void setFloatingBaseConstraint(rbd::Coords6d joint_id);

		/**
		 * @brief Sets the type of floating-base system
		 * @param enum TypeOfSystem Type of floating-base system
		 */
		void setTypeOfDynamicSystem(enum TypeOfSystem _type_of_system);


		/**
		 * @brief Sets the system DoF
		 * @param unsigned int Number of DoF
		 */
		void setSystemDoF(unsigned int _num_dof);

		/**
		 * @brief Sets the actuated joint DoF
		 * @param unsigned int Number of joints
		 */
		void setJointDoF(unsigned int _num_joints);

		/**
		 * @brief Gets the rigid body dynamic model
		 * @return const RigidBodyDynamics::Model& Rigid body dynamics model
		 */
		RigidBodyDynamics::Model& getRBDModel();

		/**
		 * @brief Gets the floating-base system DoF
		 * @return const unsigned int& Number of DoF of the floating-base system
		 */
		const unsigned int& getSystemDoF();

		/**
		 * @brief Gets the floating-base DoF
		 * @return const unsigned int& Number of floating-base DoF
		 */
		const unsigned int& getFloatingBaseDoF();

		/**
		 * @brief Gets the actuated joint DoF
		 * @return const unsigned int& Number of joint DoF
		 */
		const unsigned int& getJointDoF();

		/**
		 * @brief Gets the floating-base joint
		 * @param rbd::Coords6d Floating-base joint coordinate
		 * return const FloatingBaseJoint& Floating-base joint information
		 */
		const FloatingBaseJoint& getFloatingBaseJoint(rbd::Coords6d joint);

		/**
		 * @brief Gets the floating-base joint coordinate given an Id
		 * @param unsigned int Floating-base joint Id
		 * @return unsigned int Floating-base joint coordinate
		 */
		unsigned int getFloatingBaseJointCoordinate(unsigned int id);

		/**
		 * @brief Gets actuated joint information
		 * @return const urdf_model::JointID& Joint names and Ids
		 */
		const urdf_model::JointID& getJoints();

		/**
		 * @brief Gets the joint names list
		 * @return rbd::BodySelector& Joint names list
		 */
		rbd::BodySelector& getJointNames();

		/**
		 * @brief Gets the type of floating-base system
		 * @return enum TypeOfSystem Type of floating-base system
		 */
		enum TypeOfSystem getTypeOfDynamicSystem();

		/**
		 * @brief Gets the number of end-effectors
		 * @return const unsigned int& Number of end-effectors
		 */
		const unsigned int& getNumberOfEndEffectors();

		/**
		 * @brief Gets the end-effectors names
		 * @return const urdf_model::LinkID& Names and ids of the end-effectors
		 */
		const urdf_model::LinkID& getEndEffectors();

		/**
		 * @brief Gets the end-effector names list
		 * @return std::vector<std::string>& End-effector names list
		 */
		rbd::BodySelector& getEndEffectorNames();

		/** @brief Returns true if the system has fully floating-base */
		bool isFullyFloatingBase();

		/** @brief Returns true if the system has a virtual floating-base */
		bool isVirtualFloatingBaseRobot();

		/** @brief Returns true if the system has a physical constraint with a fully floating-base */
		bool isConstrainedFloatingBaseRobot();

		/** @brief Returns true if there are a physical constraint in the floating-base */
		bool hasFloatingBaseConstraints();

		/**
		 * @brief Converts the base and joint states to a generalized joint state
		 * @param const Vector6d& Base state
		 * @param const Eigen::VectorXd& Joint state
		 * @return Eigen::VectorXd Generalized joint state
		 */
		Eigen::VectorXd toGeneralizedJointState(const rbd::Vector6d& base_state,
												const Eigen::VectorXd& joint_state);

		/**
		 * @brief Converts the generalized joint state to base and joint states
		 * @param Vector6d& Base state
		 * @param Eigen::VectorXd& Joint state
		 * @param const Eigen::VectorXd Generalized joint state
		 */
		void fromGeneralizedJointState(rbd::Vector6d& base_state,
									   Eigen::VectorXd& joint_state,
									   const Eigen::VectorXd& generalized_state);

		/**
		 * @brief Sets the joint state given a branch values
		 * @param Eigen::VectorXd& Joint state vector
		 * @param cons Eigen::VectorXd& Branch state
		 * @param std::string Body name
		 */
		void setBranchState(Eigen::VectorXd& new_joint_state,
							const Eigen::VectorXd& branch_state,
							std::string body_name);

		/**
		 * @brief Gets the branch values given a joint state
		 * @param Eigen::VectorXd& Generalized state vector
		 * @param cons Eigen::VectorXd& Branch state
		 * @param std::string Body name
		 */
		Eigen::VectorXd getBranchState(Eigen::VectorXd& generalized_state,
									   std::string body_name);

		/**
		 * @brief Gets the position index and number of DOF of certain branch
		 * @param unsigned int& Position index of the body branch
		 * @param unsigned int& Degrees of freedom of the body branch
		 * @param std::string Name of the body branch (end-effector name)
		 */
		void getBranch(unsigned int& pos_idx,
					   unsigned int& num_dof,
					   std::string body_name);


	private:
		/** @brief Rigid-body dynamic model */
		RigidBodyDynamics::Model rbd_model;

		/** @brief Number of DoFs */
		unsigned int num_system_joints;
		unsigned int num_floating_joints;
		unsigned int num_joints;

		/** @brief System joints */
		FloatingBaseJoint AX;
		FloatingBaseJoint AY;
		FloatingBaseJoint AZ;
		FloatingBaseJoint LX;
		FloatingBaseJoint LY;
		FloatingBaseJoint LZ;
		urdf_model::JointID joints;
		std::vector<std::string> joint_names_;

		/** @brief Type of system */
		enum TypeOfSystem type_of_system;

		/** @brief End-effector information */
		urdf_model::LinkID end_effectors;
		unsigned int num_end_effectors;
		rbd::BodySelector end_effector_names_;
};

} //@namespace
} //@namespace dwl

#endif