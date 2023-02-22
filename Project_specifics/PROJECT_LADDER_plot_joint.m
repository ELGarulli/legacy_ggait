function [start_plot_joint, end_plot_joint, joint_angle] = PROJECT_LADDER_plot_joint(gait_type, SIDE, joint_angle)

switch gait_type
    case 1 %bipedal
        start_plot_joint=1; % yes CREST marker
        end_plot_joint=3; % no MTP joint in MOUSE PROJECT
    case 2 %quadupedal
        if SIDE>2,
            start_plot_joint=1; %no SCAP marker
            end_plot_joint=3; %no TOE MTP joints in MOUSE PROJECT
            joint_angle(:,1)=0;
            joint_angle(1,1)=1;
        else
            start_plot_joint=1; % yes CREST marker
            end_plot_joint=3; % no TOE MTP joints in MOUSE PROJECT
        end
end