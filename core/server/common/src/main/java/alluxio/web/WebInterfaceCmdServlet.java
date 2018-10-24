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

import alluxio.client.file.FileSystem;
import alluxio.exception.AlluxioException;
import alluxio.wire.MountPointInfo;

import javax.annotation.concurrent.ThreadSafe;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Map;

@ThreadSafe
public final class WebInterfaceCmdServlet extends WebInterfaceAbstractMetricsServlet {
	private static final long serialVersionUID = -1481253168100363787L;
	private static final FileSystem fs = FileSystem.Factory.get();

	/**
	 * Create a {@link WebInterfaceCmdServlet} instance.
	 */
	public WebInterfaceCmdServlet() {
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
		getServletContext().getRequestDispatcher("/cmd.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) {

		Path alluxioPath = Paths.get("bin", "alluxio").toAbsolutePath();

		String cmd = request.getParameter("cmd");

		try {
			Runtime rt = Runtime.getRuntime();
			Process proc = rt.exec(String.format("%s fs %s", alluxioPath.toString(), cmd));

			BufferedReader stdInput = new BufferedReader(new
				InputStreamReader(proc.getInputStream()));

			BufferedReader stdError = new BufferedReader(new
				InputStreamReader(proc.getErrorStream()));

			String s;
			while ((s = stdInput.readLine()) != null) {
				response.getWriter().write(String.format("%s\n", s));
			}

			while ((s = stdError.readLine()) != null) {
				response.getWriter().write(String.format("%s\n", s));
			}

		} catch (IOException e) {
			e.printStackTrace();
		}
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
