defmodule Hub do
  use Ash.Domain,
    otp_app: :nerves_hub

  resources do
    resource Hub.Archive do
      define :update_archive, action: :update
      define :create_archive, action: :create
      define :destroy_archive, action: :destroy
      define :list_archives, action: :read
    end

    resource Hub.AuditLog do
      define :update_audit_log, action: :update
      define :create_audit_log, action: :create
      define :destroy_audit_log, action: :destroy
      define :list_audit_logs, action: :read
    end

    resource Hub.CaCertificate do
      define :update_ca_certificate, action: :update
      define :create_ca_certificate, action: :create
      define :destroy_ca_certificate, action: :destroy
      define :list_ca_certificates, action: :read
    end

    resource Hub.Deployment do
      define :update_deployment, action: :update
      define :create_deployment, action: :create
      define :destroy_deployment, action: :destroy
      define :list_deployments, action: :read
    end

    resource Hub.DeviceCertificate do
      define :update_device_certificate, action: :update
      define :create_device_certificate, action: :create
      define :destroy_device_certificate, action: :destroy
      define :list_device_certificates, action: :read
    end

    resource Hub.DeviceConnection do
      define :update_device_connection, action: :update
      define :create_device_connection, action: :create
      define :destroy_device_connection, action: :destroy
      define :list_device_connections, action: :read
    end

    resource Hub.DeviceHealth do
      define :update_device_health, action: :update
      define :create_device_health, action: :create
      define :destroy_device_health, action: :destroy
      define :list_device_healths, action: :read
    end

    resource Hub.DeviceMetric do
      define :update_device_metric, action: :update
      define :create_device_metric, action: :create
      define :destroy_device_metric, action: :destroy
      define :list_device_metrics, action: :read
    end

    resource Hub.DeviceSharedSecretAuth do
      define :update_device_shared_secret_auth, action: :update
      define :create_device_shared_secret_auth, action: :create
      define :destroy_device_shared_secret_auth, action: :destroy
      define :list_device_shared_secret_auths, action: :read
    end

    resource Hub.Device do
      define :update_device, action: :update
      define :create_device, action: :create
      define :destroy_device, action: :destroy
      define :list_devices, action: :read
    end

    resource Hub.FirmwareDelta do
      define :update_firmware_delta, action: :update
      define :create_firmware_delta, action: :create
      define :destroy_firmware_delta, action: :destroy
      define :list_firmware_deltas, action: :read
    end

    resource Hub.FirmwareTransfer do
      define :update_firmware_transfer, action: :update
      define :create_firmware_transfer, action: :create
      define :destroy_firmware_transfer, action: :destroy
      define :list_firmware_transfers, action: :read
    end

    resource Hub.Firmware do
      define :update_firmware, action: :update
      define :create_firmware, action: :create
      define :destroy_firmware, action: :destroy
      define :list_firmwares, action: :read
    end

    resource Hub.InflightDeploymentCheck do
      define :update_inflight_deployment_check, action: :update
      define :create_inflight_deployment_check, action: :create
      define :destroy_inflight_deployment_check, action: :destroy
      define :list_inflight_deployment_checks, action: :read
    end

    resource Hub.InflightUpdate do
      define :update_inflight_update, action: :update
      define :create_inflight_update, action: :create
      define :destroy_inflight_update, action: :destroy
      define :list_inflight_updates, action: :read
    end

    resource Hub.Invite do
      define :update_invite, action: :update
      define :create_invite, action: :create
      define :destroy_invite, action: :destroy
      define :list_invites, action: :read
    end

    resource Hub.Jitp do
      define :update_jitp, action: :update
      define :create_jitp, action: :create
      define :destroy_jitp, action: :destroy
      define :list_jitps, action: :read
    end

    resource Hub.ObanJob do
      define :update_oban_job, action: :update
      define :create_oban_job, action: :create
      define :destroy_oban_job, action: :destroy
      define :list_oban_jobs, action: :read
    end

    resource Hub.ObanPeer do
      define :update_oban_peer, action: :update
      define :create_oban_peer, action: :create
      define :destroy_oban_peer, action: :destroy
      define :list_oban_peers, action: :read
    end

    resource Hub.OrgKey do
      define :update_org_key, action: :update
      define :create_org_key, action: :create
      define :destroy_org_key, action: :destroy
      define :list_org_keys, action: :read
    end

    resource Hub.OrgMetric do
      define :update_org_metric, action: :update
      define :create_org_metric, action: :create
      define :destroy_org_metric, action: :destroy
      define :list_org_metrics, action: :read
    end

    resource Hub.OrgUser do
      define :update_org_user, action: :update
      define :create_org_user, action: :create
      define :destroy_org_user, action: :destroy
      define :list_org_users, action: :read
    end

    resource Hub.Org do
      define :update_org, action: :update
      define :create_org, action: :create
      define :destroy_org, action: :destroy
      define :list_orgs, action: :read
    end

    resource Hub.PinnedDevice do
      define :update_pinned_device, action: :update
      define :create_pinned_device, action: :create
      define :destroy_pinned_device, action: :destroy
      define :list_pinned_devices, action: :read
    end

    resource Hub.ProductSharedSecretAuth do
      define :update_product_shared_secret_auth, action: :update
      define :create_product_shared_secret_auth, action: :create
      define :destroy_product_shared_secret_auth, action: :destroy
      define :list_product_shared_secret_auths, action: :read
    end

    resource Hub.ProductUser do
      define :update_product_user, action: :update
      define :create_product_user, action: :create
      define :destroy_product_user, action: :destroy
      define :list_product_users, action: :read
    end

    resource Hub.Product do
      define :update_product, action: :update
      define :create_product, action: :create
      define :destroy_product, action: :destroy
      define :list_products, action: :read
    end

    resource Hub.Script do
      define :update_script, action: :update
      define :create_script, action: :create
      define :destroy_script, action: :destroy
      define :list_scripts, action: :read
    end

    resource Hub.UserCertificate do
      define :update_user_certificate, action: :update
      define :create_user_certificate, action: :create
      define :destroy_user_certificate, action: :destroy
      define :list_user_certificates, action: :read
    end

    resource Hub.UserToken do
      define :update_user_token, action: :update
      define :create_user_token, action: :create
      define :destroy_user_token, action: :destroy
      define :list_user_tokens, action: :read
    end

    resource Hub.User do
      define :update_user, action: :update
      define :create_user, action: :create
      define :destroy_user, action: :destroy
      define :list_users, action: :read
    end
  end
end
