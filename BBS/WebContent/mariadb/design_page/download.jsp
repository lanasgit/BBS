<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.io.FileInputStream" %>
<%@ page import="java.net.URLEncoder" %>
<%
	String fileName = request.getParameter("filename");
	String downPath = "C:/Users/KIM/git/repository/BBS/WebContent/upload/" + fileName;
	out.clearBuffer();
	response.setContentType("application/octet-stream");
	response.setHeader("Content-Disposition", "attachment;filename=" + URLEncoder.encode(fileName, "utf-8"));																		
	FileInputStream fis = new FileInputStream(downPath);
	ServletOutputStream sos = response.getOutputStream();
	int data;
	byte readByte[] = new byte[4096];
	while((data = fis.read(readByte, 0, readByte.length)) != -1) {
		sos.write(readByte, 0, data);
	}
	sos.flush();
	sos.close();
	fis.close();
%>
