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

<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="java.io.File" %>
<%
	request.setCharacterEncoding("utf-8");

	String uploadPath = "C:/Users/KIM/git/repository/BBS/WebContent/upload";
	int maxFileSize = 1024 * 1024 * 5; //약 5MB
	String encType = "utf-8";
	
	MultipartRequest multi = new MultipartRequest(request, uploadPath, maxFileSize, encType, new DefaultFileRenamePolicy());

	String cpage = multi.getParameter("cpage");
	String seq = multi.getParameter("seq");

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
	ResultSet rs = null;
	
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
		
		sql = "select grp, grp, grps, grpl from board1 where seq=?"; 
		pstmt = conn.prepareStatement(sql);
		pstmt.setString(1, seq);
		
		rs = pstmt.executeQuery();
		
		//결과 1개
		int grp = 0;
		int grps = 0;
		int grpl = 0;
		if (rs.next()) {
			grp = rs.getInt("grp");
			grps = rs.getInt("grps");
			grpl = rs.getInt("grpl");
		}
		
		sql = "update board1 set grps = grps+1 where grp=? and grps > ?";
		pstmt = conn.prepareStatement(sql);
		pstmt.setInt(1, grp);
		pstmt.setInt(2, grps);
		pstmt.executeUpdate();
		
		
		sql = "insert into board1 values (0, ?, ?, ?, ?, ?, 0, ?, now(), ?, ?, ?, ?, ?, ?)";
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
		pstmt.setInt(10, grp);
		pstmt.setInt(11, grps + 1);
		pstmt.setInt(12, grpl + 1);
		
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
		out.println("alert('답글이 작성되었습니다.');");
		out.println("location.href='./board_view1.jsp?cpage="+ cpage +"&seq="+ seq +"';");
	} else {
		out.println("alert('답글쓰기에 실패했습니다.');");
		out.println("history.back();");
	}
	out.println("</script>");
%>