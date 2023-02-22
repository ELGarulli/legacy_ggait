function [mkr] = PROJECT_MOUSE_mkr(mkr)

mkr.RTip=mkr.RMTP;
mkr.LTip=mkr.LMTP;
mkr.RTip=mkr.RMTP;
mkr.LTip=mkr.LMTP;
mkr.RToe=mkr.RMTP;
mkr.LToe=mkr.LMTP;
if isfield(mkr, 'Lshoulder')
    mkr.RScap=mkr.Rshoulder;
    mkr.LScap=mkr.Lshoulder;
end
