/*
 * The Alluxio Open Foundation licenses this work under the Apache License, version 2.0
 * (the "License"). You may not use this work except in compliance with the License, which is
 * available at www.apache.org/licenses/LICENSE-2.0
 *
 * This software is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
 * either express or implied, as more fully set forth in the License.
 *
 * See the NOTICE file distributed with this work for information regarding copyright ownership.
 */

package alluxio.web;

import alluxio.AlluxioURI;
import alluxio.client.file.FileSystem;
import alluxio.client.file.options.MountOptions;
import alluxio.exception.AlluxioException;
import alluxio.wire.MountPointInfo;
import org.json.JSONObject;

import javax.annotation.concurrent.ThreadSafe;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@ThreadSafe
public final class WebInterfaceMountServlet extends WebInterfaceAbstractMetricsServlet {
	private static final long serialVersionUID = -1481253168100363787L;
	private static final FileSystem fs = FileSystem.Factory.get();

	/**
	 * Create a {@link WebInterfaceMountServlet} instance.
	 */
	public WebInterfaceMountServlet() {
		super();
	}

	/**
	 * Redirects the request to a JSP after populating attributes via populateValues.
	 *
	 * @param request  the {@link HttpServletRequest} object
	 * @param response the {@link HttpServletResponse} object
	 * @throws ServletException if the target resource throws this exception
	 */
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
		throws ServletException, IOException {
		populateValues(request);
		getServletContext().getRequestDispatcher("/mount.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
		throws ServletException, IOException {

		JSONObject result;
		result = new JSONObject();
		response.setContentType("application/json");
		response.setStatus(201);

		String alluxio_underfs_address = request.getParameter("alluxio_underfs_address");
		String alluxio_uri = request.getParameter("alluxio_uri");
		String ufsType = request.getParameter("ufsType");
		String readOnly = request.getParameter("read_only");
		String aws_access_key_id;
		String aws_secret_key_id;
		String endpoint;
		String s3_bucket;
		String folder;
		String s3_disable_dns_buckets;
		String s3a_inherit_acl;
		String container;

		MountOptions mountOptions = MountOptions.defaults();
		mountOptions.setReadOnly(readOnly.equals("1"));

		Map<String, String> _opts = new HashMap<>();
		try {
			request.setAttribute("fatalError", "");

			switch (ufsType) {
				case "hdfs":
					break;
				case "glusterfs":
					break;
				case "mapr":
					break;
				case "nfs":
					break;
				case "swift":
					container = request.getParameter("container");
					folder = request.getParameter("folder");

					String user = request.getParameter("user");
					String tenant = request.getParameter("tenant");
					String password = request.getParameter("password");
					String auth_url = request.getParameter("auth_url");
					String use_public_url = request.getParameter("use_public_url");
					String auth_method = request.getParameter("auth_method");

					alluxio_underfs_address = "swift://" + container + "/" + folder;

					_opts.put("fs.swift.user", user);
					_opts.put("fs.swift.tenant", tenant);
					_opts.put("fs.swift.password ", password);
					_opts.put("fs.swift.auth.url", auth_url);
					_opts.put("fs.swift.use.public.url", use_public_url.equals("1") ? "true" : "false");
					_opts.put("fs.swift.auth.method ", auth_method);
					break;

				case "s3":
					aws_access_key_id = request.getParameter("aws_access_key_id");
					aws_secret_key_id = request.getParameter("aws_secret_key_id");
					s3_bucket = request.getParameter("s3_bucket");
					String s3_directory = request.getParameter("s3_directory");

					_opts.put("aws.accessKeyId", aws_access_key_id);
					_opts.put("aws.secretKey", aws_secret_key_id);
					alluxio_underfs_address = "s3a://" + s3_bucket + "/" + s3_directory;
					break;
				case "minio":
					endpoint = request.getParameter("endpoint");
					String minio_bucket = request.getParameter("minio_bucket");
					String minio_directory = request.getParameter("minio_directory");
					String minio_access_key_id = request.getParameter("minio_access_key_id");
					String minio_secret_key_id = request.getParameter("minio_secret_key_id");
					s3a_inherit_acl = request.getParameter("s3a_inherit_acl");
					s3_disable_dns_buckets = request.getParameter("s3_disable_dns_buckets");

					alluxio_underfs_address = "s3a://" + minio_bucket + "/" + minio_directory;

					_opts.put("alluxio.underfs.s3.endpoint", endpoint);
					_opts.put("aws.accessKeyId", minio_access_key_id);
					_opts.put("aws.secretKey", minio_secret_key_id);
					_opts.put("alluxio.underfs.s3a.inherit_acl", s3a_inherit_acl.equals("1") ? "true" : "false");
					_opts.put("alluxio.underfs.s3.disable.dns.buckets", s3_disable_dns_buckets.equals("1") ? "true" : "false");
					break;
				case "wasb":
					String azure_container = request.getParameter("azure_container");
					String azure_account = request.getParameter("azure_account");
					String azure_directory = request.getParameter("azure_directory");
					String azure_access_key = request.getParameter("azure_access_key");
					s3_disable_dns_buckets = request.getParameter("s3_disable_dns_buckets");

					alluxio_underfs_address = String.format("wasb://%s@%s.blob.core.windows.net/%s",
						azure_container, azure_account, azure_directory);

					_opts.put("alluxio.underfs.s3.disable.dns.buckets", s3_disable_dns_buckets.equals("1") ? "true" : "false");
					_opts.put(String.format("alluxio.master.mount.table.root.option.fs.azure.account.key.%s.blob.core.windows.net",
						azure_account), azure_access_key);
					break;
				case "ceph":
					aws_access_key_id = request.getParameter("aws_access_key_id");
					aws_secret_key_id = request.getParameter("aws_secret_key_id");
					endpoint = request.getParameter("endpoint");
					s3_bucket = request.getParameter("s3_bucket");
					folder = request.getParameter("folder");
					s3a_inherit_acl = request.getParameter("s3a_inherit_acl");
					s3_disable_dns_buckets = request.getParameter("s3_disable_dns_buckets");

					alluxio_underfs_address = String.format("s3a://%s/%s", s3_bucket, folder);

					_opts.put("aws.accessKeyId", aws_access_key_id);
					_opts.put("aws.secretKey", aws_secret_key_id);
					_opts.put("alluxio.underfs.s3.endpoint", endpoint);
					_opts.put("alluxio.underfs.s3a.inherit_acl", s3a_inherit_acl.equals("1") ? "true" : "false");
					_opts.put("alluxio.underfs.s3.disable.dns.buckets", s3_disable_dns_buckets.equals("1") ? "true" : "false");
					break;
				case "oss":
					String oss_access_key_id = request.getParameter("oss_access_key_id");
					String oss_access_key_secret = request.getParameter("oss_access_key_secret");
					String oss_endpoint = request.getParameter("oss_endpoint");

					s3_bucket = request.getParameter("oss_bucket");
					folder = request.getParameter("oss_directory");

					alluxio_underfs_address = String.format("oss://%s/%s", s3_bucket, folder);

					_opts.put("fs.oss.accessKeyId", oss_access_key_id);
					_opts.put("fs.oss.accessKeySecret", oss_access_key_secret);
					_opts.put("fs.oss.endpoint", oss_endpoint);
					break;
				case "obs":
					String obs_access_key_id = request.getParameter("obs_access_key_id");
					String obs_access_key_secret = request.getParameter("obs_access_key_secret");
					String obs_endpoint = request.getParameter("obs_endpoint");

					s3_bucket = request.getParameter("obs_bucket");
					folder = request.getParameter("obs_directory");

					alluxio_underfs_address = String.format("obs://%s/%s", s3_bucket, folder);

					_opts.put("fs.obs.accessKey", obs_access_key_id);
					_opts.put("fs.obs.secretKey", obs_access_key_secret);
					_opts.put("fs.oss.endpoint", obs_endpoint);
					break;
				default:
					break;
			}

			mountOptions.setProperties(_opts);
			fs.mount(new AlluxioURI(alluxio_uri), new AlluxioURI(alluxio_underfs_address), mountOptions);
			result.put("message", "Mount " + alluxio_uri + " succeed!");
		} catch (AlluxioException | IOException e) {
			result.put("message", e.getMessage());
			response.setStatus(500);
		}
		response.getWriter().write(result.toString());
	}

	@Override
	protected void doDelete(HttpServletRequest request, HttpServletResponse response)
		throws ServletException, IOException {
		request.setAttribute("fatalError", "");
		String path = request.getParameter("path");
		System.out.print(path);
		try {
			fs.unmount(new AlluxioURI(path));
		} catch (AlluxioException e) {
			e.printStackTrace();
		}
		getServletContext().getRequestDispatcher("/mount.jsp").forward(request, response);
	}

	/**
	 *   
	 * Populates key, value pairs for UI display.
	 *
	 * @param request The {@link HttpServletRequest} object
	 */
	private void populateValues(HttpServletRequest request) {
		request.setAttribute("fatalError", "");
		Map<String, MountPointInfo> mountTable = null;
		try {
			mountTable = fs.getMountTable();
		} catch (IOException | AlluxioException e) {
			e.printStackTrace();
		}

		request.setAttribute("mountTable", mountTable);
	}
}
