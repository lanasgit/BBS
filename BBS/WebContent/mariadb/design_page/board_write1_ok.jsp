<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="javax.naming.Context" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="javax.naming.NamingException" %>

<%@ page import="javax.sql.DataSource" %>

<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.SQLException" %>

<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="java.io.File" %>
<%
	request.setCharacterEncoding("utf-8");

	String uploadPath = "C:/Users/KIM/git/repository/BBS/WebContent/upload";
	int maxFileSize = 1024 * 1024 * 5; //약 5MB
	String encType = "utf-8";

	MultipartRequest multi = new MultipartRequest(request, uploadPath, maxFileSize, encType, new DefaultFileRenamePolicy());

	String writer = multi.getParameter("writer");
	String subject = multi.getParameter("subject");
	String password = multi.getParameter("password");
	String content = multi.getParameter("content");
	String emot = multi.getParameter("emot").substring(4,6);
	String mail = "";
	if (!multi.getParameter("mail1").equals("") && !multi.getParameter("mail2").equals("")) {
		mail = multi.getParameter("mail1") + "@" + multi.getParameter("mail2");
	}
	String filename = multi.getFilesystemName("upload");
	long filesize = 0;
	File file = multi.getFile("upload");
	if (file != null) {
		filesize = file.length();
	}
	String wip = request.getRemoteAddr();
	
	Connection conn = null;
	PreparedStatement pstmt = null;
	
	//성공, 실패 표현
	int flag = 1;
	
	try {
		Context initCtx = new InitialContext();
		Context envCtx = (Context)initCtx.lookup("java:comp/env");
		DataSource dataSource = (DataSource)envCtx.lookup("jdbc/mariadb1");
		
		conn = dataSource.getConnection();
		
		//자동증가 컬럼(seq : 게시글 번호) 초기화 먼저 실행
		String sql = "alter table board1 auto_increment = 1";
		pstmt = conn.prepareStatement(sql);
		pstmt.executeUpdate();
		pstmt.close();
		
		sql = "insert into board1 values (0, ?, ?, ?, ?, ?, 0, ?, now(), ?, ?, ?)";
		pstmt = conn.prepareStatement(sql);
		
		pstmt.setString(1, subject);
		pstmt.setString(2, writer);
		pstmt.setString(3, mail);
		pstmt.setString(4, password);
		pstmt.setString(5, content);
		pstmt.setString(6, wip);
		pstmt.setString(7, emot);
		pstmt.setString(8, filename);
		pstmt.setLong(9, filesize);
		
		int result = pstmt.executeUpdate();
		if (result == 1) {
			flag = 0;
		} 	
	} catch (NamingException e) {
		System.out.println("[에러] : " + e.getMessage());
	} catch (SQLException e) {
		System.out.println("[에러] : " + e.getMessage());
	} finally {
		if (pstmt != null) pstmt.close();
		if (conn != null) conn.close();
	}
	out.println("<script type='text/javascript'>");
	if (flag == 0) {
		out.println("alert('글이 작성되었습니다.');");
		out.println("location.href='./board_list1.jsp';");
	} else {
		out.println("alert('글쓰기에 실패했습니다.');");
		out.println("history.back();");
	}
	out.println("</script>");
%>