defmodule Hub do
  use Ash.Domain,
    otp_app: :nerves_hub

  resources do
    resource Hub.Archive
    resource Hub.AuditLog
    resource Hub.CaCertificate
    resource Hub.Deployment
    resource Hub.DeviceCertificate
    resource Hub.DeviceConnection
    resource Hub.DeviceHealth
    resource Hub.DeviceMetric
    resource Hub.DeviceSharedSecretAuth
    resource Hub.Device
    resource Hub.FirmwareDelta
    resource Hub.FirmwareTransfer
    resource Hub.Firmware
    resource Hub.InflightDeploymentCheck
    resource Hub.InflightUpdate
    resource Hub.Invite
    resource Hub.Jitp
    resource Hub.ObanJob
    resource Hub.ObanPeer
    resource Hub.OrgKey
    resource Hub.OrgMetric
    resource Hub.OrgUser
    resource Hub.Org
    resource Hub.PinnedDevice
    resource Hub.ProductSharedSecretAuth
    resource Hub.ProductUser
    resource Hub.Product
    resource Hub.Script
    resource Hub.UserCertificate
    resource Hub.UserToken
    resource Hub.User
  end
end
