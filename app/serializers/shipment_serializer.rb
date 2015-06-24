class ShipmentSerializer < ActiveModel::Serializer
  self.root = false

  attributes :status
end