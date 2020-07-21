<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="javax.naming.Context" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="javax.naming.NamingException" %>

<%@ page import="javax.sql.DataSource" %>

<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%
	request.setCharacterEncoding("utf-8");

	String writer = request.getParameter("writer");
	String password = request.getParameter("password");
	
	Connection conn = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	
	int flag = 1;
	
	try {
		Context initCtx = new InitialContext();
		Context envCtx = (Context)initCtx.lookup("java:comp/env");
		DataSource dataSource = (DataSource)envCtx.lookup("jdbc/mariadb2");
		
		conn = dataSource.getConnection();
		
		String sql = "select * from user where user=? && password = password(?)";
		pstmt = conn.prepareStatement(sql);
		pstmt.setString(1, writer);
		pstmt.setString(2, password);
		rs = pstmt.executeQuery();
		if (rs.next()) {
			flag = 0;
			
			session.setAttribute("s_id", writer);
			session.setAttribute("s_grade", "A등급");
		}
	} catch (NamingException e) {
		System.out.println("[에러] : " + e.getMessage());
	} catch (SQLException e) {
		System.out.println("[에러] : " + e.getMessage());
	} finally {
		if (rs != null) try {rs.close();} catch (SQLException e) {}
		if (pstmt != null) try {pstmt.close();} catch (SQLException e) {}
		if (conn != null) try {conn.close();} catch (SQLException e) {}
	}
	out.println("<script type='text/javascript'>");
	if (flag == 0) {
		out.println("alert('로그인 성공');");
		out.println("location.href='./board_list1.jsp';");
	} else {
		out.println("alert('로그인 실패');");
		out.println("history.back();");
	}
	out.println("</script>");
%>