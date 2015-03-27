function newModel = updateObjectModel(objectModel, predictedProposalModel, objectModelUpdateParameter)
newModel = (objectModelUpdateParameter)*predictedProposalModel + (1-objectModelUpdateParameter)*objectModel;
end