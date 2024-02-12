classdef node
  %NODE Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    sType
    voltage_pu
    phi_rad
    p_pu
    q_pu
    index
  end
  
  methods
    function obj = node(sType, arg1, arg2, arg3)
      %NODE Construct an instance of this class
      % 
      % Args:
      %     param1 (str): type of node
      %     param2 (double): known value 1 depends on node-type
      %     param3 (double): known value 2 depends on node-type
      %     param4 (int): index of node
      % 
      % Returns:
      %     Instance: a node instance
      % 
      % Examples:
      %     create a PV-node with P=0.5pu and U=1.01pu
      %     >>> myNode = node('PV', 0.5, 1.01)
      
      % initialize the type of node
      obj.sType = sType;
      obj.index = arg3;
      if obj.sType == "PV"
        obj.p_pu = arg1;
        obj.voltage_pu = arg2;
      elseif obj.sType == "PQ"
        obj.p_pu = arg1;
        obj.q_pu = arg2;
      elseif obj.sType == "Slack"
        obj.voltage_pu = 1.0;
        obj.phi_rad = 0;
      else
        % throw error
        msg = sprintf(['the given type of the node: %s is not defined!\n' ...
                       'The node type should be one of PV, PQ or Slack'], obj.sType);
        error(msg);
      end
    end
    
    function getInfo(obj)
      %Getter method, display all the infomation of node
      fprintf('type: %s\n', obj.sType);
      fprintf('voltage[p.u.]: %.3f\n', obj.voltage_pu);
      fprintf('phi [rad]: %.3f\n', obj.phi_rad);
      fprintf('p [p.u.]: %.3f\n', obj.p_pu);
      fprintf('q [p.u.]: %.3f\n', obj.q_pu);
    end

    function obj = setVal(obj, sPropertyName, newVal)
      if isprop(obj, sPropertyName)
        obj = setfield(obj, sPropertyName, newVal);
      else
        error(sprintf(['the property name: %s does not exist!'], sPropertyName));
      end
    end
  end
end

